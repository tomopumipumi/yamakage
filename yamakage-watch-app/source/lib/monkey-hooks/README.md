# 🐒 MonkeyHooks

MonkeyHooks is a **reactive state management and hooks-oriented utility library** designed for Garmin Connect IQ (MonkeyC) application development.

It provides intuitive APIs similar to React's `useState`, `useMemo`, and `useEffect`, and is structured to help build complex Garmin app UI state management, system resource (timers and GPS) sharing, and screen transitions (routing) in a simple and safe manner.

---

## 💡 Philosophy

MonkeyHooks is designed around four core paradigms:

1. **Single Source of Truth:**
Maintains a global `Store` shared across the entire application under the hood. State is centrally managed via keys (typically Symbols), allowing access and updates from anywhere.
2. **Automatic Reactivity:**
When state is updated via `set()`, the framework detects the change, automatically calls `WatchUi.requestUpdate()`, and re-evaluates dependent listeners and `Computed` (computed properties). Developers do not need to manually trigger render updates.
3. **Enhanced Type and Null Safety:**
To address MonkeyC's duck-typing characteristics, type-specific contexts such as `useNumber` and `useString` are provided. Additionally, the `req()` method guarantees that a value exists (throwing an exception if `null`), promoting safe programming practices.
4. **System Resource Optimization:**
`SharedTimer` and `LocationHook` share a single underlying system resource (`Timer.Timer` or `Position` events) even when subscribed to by multiple components, minimizing battery consumption and memory usage.

---

## Architecture

```mermaid
graph TD
    classDef store fill:#fbd462,stroke:#b38c20,stroke-width:2px,color:#000
    classDef hooks fill:#81d4fa,stroke:#0277bd,stroke-width:2px,color:#000
    classDef sys fill:#a5d6a7,stroke:#2e7d32,stroke-width:2px,color:#000
    classDef view fill:#ce93d8,stroke:#6a1b9a,stroke-width:2px,color:#000
    classDef comp fill:#f48fb1,stroke:#6a1b9a,stroke-width:1px,color:#000
    classDef os fill:#eeeeee,stroke:#9e9e9e,stroke-width:2px,color:#000
    classDef custom fill:#e1bee7,stroke:#6a1b9a,stroke-width:2px,stroke-dasharray: 4 4,color:#000

    subgraph "Garmin OS / Hardware"
        Sensors((GPS / Timer)):::os
        Storage[(Local Storage)]:::os
        Screen((Watch Screen)):::os
    end

    subgraph "MonkeyHooks Framework"
        SystemH["System Hooks<br/>(LocationHook, SharedTimer)"]:::sys
        Router[Data-Driven Router<br/>Automatic Routing]:::sys
        Store[(Global Store<br/>Centralized State Management)]:::store
        
        Hooks["Type-Safe Hooks<br/>(useNumber, useString...)"]:::hooks
        Computed[useComputed<br/>Calculation & Caching]:::hooks
    end

    subgraph "Your Application"
        Delegate[Behavior Delegate<br/>User Actions]:::view
        View[View<br/>Subscription & Management]:::view
        Dumb[Dumb Components<br/>Pure UI Rendering Functions]:::comp
    end

    Sensors -->|Shared Single Resource| SystemH
    Storage <-->|Auto Save/Restore| Hooks
    
    SystemH -->|Callback| View
    Delegate -->|"set() State Update"| Hooks
    Hooks -->|Write| Store
    
    Store -->|Read / Notification| Hooks
    Store -->|Read| Computed

    Hooks -->|Composition/Extension| CustomH
    Computed -->|Composition/Extension| CustomH
    CustomH -->|Structured Domain Data| View
    Hooks --->|"get() req() Direct Use"| View
    
    View -->|Pass as Arguments| Dumb
    Dumb -->|Render| Screen
    
    Store -.->|Detect Route_ID| Router
    Router -.->|push / switchTo| Screen

```

## 🚀 Installation

Place the `source/lib/monkey-hooks/` directory from this repository into your project's `source/` directory. All modules are provided under the `MonkeyHooks` module namespace.

---

## 📖 Usage

### 1. Basic State Management

Basic hooks for reading and writing state. Type-specific hooks (`useNumber`, `useString`, `useBoolean`, `useFloat`, `useFont`, `useColor`) are available.

```monkeyc
import Toybox.WatchUi;
import Toybox.Lang;

class MyView extends WatchUi.View {
    // Manage Number state with the key ':counter'
    private var _counter = MonkeyHooks.useNumber(:counter);

    function initialize() {
        View.initialize();
        // Set initial value (ignored if the value already exists)
        _counter.init(0);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        // get() allows null. req() guarantees non-null (crashes if null)
        var currentValue = _counter.req();
        dc.drawText(100, 100, Graphics.FONT_LARGE, "Count: " + currentValue, Graphics.TEXT_JUSTIFY_CENTER);
    }
}

// Update values in a delegate class or elsewhere
class MyDelegate extends WatchUi.BehaviorDelegate {
    private var _counter = MonkeyHooks.useNumber(:counter);

    function onSelect() {
        // Updating the value automatically triggers WatchUi.requestUpdate()
        _counter.set(_counter.req() + 1);
        return true;
    }
}

```

### 2. Computed Properties (useComputed)

Creates derived state that is automatically calculated based on other states. It improves performance by recalculating only when dependent states (Deps) change.

```monkeyc
class UserProfile {
    private var _weight = MonkeyHooks.useNumber(:weight).init(70);
    private var _height = MonkeyHooks.useNumber(:height).init(175);
    
    // Computed property to calculate BMI
    private var _bmi = MonkeyHooks.useComputed(
        :bmi,             // Storage key
        [:weight, :height], // Array of dependent state keys
        method(:calcBmi)    // Calculation method
    );

    // Dependent values are passed as an Array
    function calcBmi(deps as Array) as Float {
        var w = deps[0] as Number;
        var h = (deps[1] as Number) / 100.0;
        return w / (h * h);
    }

    function printBmi() {
        // calcBmi runs only when weight or height changes; otherwise, cached values are returned
        System.println("BMI: " + _bmi.req());
    }
}

```

### 3. State Watching (useWatch)

A hook for executing side effects (callbacks) when specific state values change, equivalent to React's `useEffect`.

```monkeyc
class Logger {
    private var _watcher;

    function initialize() {
        _watcher = MonkeyHooks.useWatch(
            [:counter], 
            method(:onCounterChanged)
        );
    }

    function onCounterChanged(currentValues as Array) as Void {
        System.println("Counter is now: " + currentValues[0]);
    }
}

```

### 4. Persistent Storage Hook (useStorageString)

Integrates with `Application.Storage` to easily create state that persists across app sessions.

```monkeyc
// Saves to storage under the "username" key while synchronizing with the in-memory Store
var userName = MonkeyHooks.useStorageString("username").init("Guest");

// Calling this updates the in-memory Store and executes Storage.setValue() simultaneously
userName.set("Bob"); 

```

### 5. Resource Sharing Hooks (SharedTimer / LocationHook)

Safely shares high-cost resources. Resources start when the first listener registers and automatically stop when listeners drop to zero.

#### SharedTimer

A shared timer that triggers a tick every 100ms, ideal for animations and periodic processing.

```monkeyc
function initialize() {
    MonkeyHooks.SharedTimer.subscribe(method(:onTick));
}

function onTick() as Void {
    // Process called every 100ms
}

function cleanup() {
    // Unsubscribe (the Timer stops automatically if no other listeners remain)
    MonkeyHooks.SharedTimer.unsubscribe(method(:onTick));
}

```

#### LocationHook

A shared GPS (Position) event listener.

```monkeyc
function initialize() {
    MonkeyHooks.LocationHook.subscribe(method(:onLocationUpdated));
}

function onLocationUpdated(info as Position.Info) as Void {
    System.println("Lat: " + info.position.toDegrees()[0]);
}

```

### 6. Routing (MonkeyRouter)

Centrally manages View and Delegate creation to handle screen transitions cleanly.

**Initial Setup:**

```monkeyc
// Initialize in App.mc, etc.
function onStart(state) {
    MonkeyHooks.Router.initialize(method(:viewFactory));
}

// Accepts a Route ID and returns an array of [View, Delegate]
function viewFactory(routeId as Number) as Array? {
    switch(routeId) {
        case 1:
            return [new HomeView(), new HomeDelegate()];
        case 2:
            return [new SettingsView(), null];
    }
    return null;
}

```

**Screen Transition:**

```monkeyc
// Transition to Home screen (equivalent to pushView)
MonkeyHooks.Router.push(1, WatchUi.SLIDE_LEFT);

// Replace current screen (equivalent to switchToView)
MonkeyHooks.Router.switchTo(2, WatchUi.SLIDE_IMMEDIATE);

```

---

## 🏗 Best Practices for Medium to Large-Scale Development

### Centralized Key Management (Using Enums)

Symbols (like `:counter`) are convenient for small apps or temporary local states, but as app scale increases, typos can lead to bugs. For medium to large-scale development, using an `enum` to centrally manage global state keys is recommended.

```monkeyc
// Centrally manage state keys using a module and enum
module AppState {
    enum {
        DISPLAY_WIDTH,
        DISPLAY_HEIGHT,
        IS_GPS_READY,
        USER_PROFILE
    }
}

class MainView extends WatchUi.View {
    function onUpdate(dc) {
        // Using enums prevents typos and enhances IDE auto-completion
        var w = MonkeyHooks.useNumber(AppState.DISPLAY_WIDTH).req();
        var isReady = MonkeyHooks.useBoolean(AppState.IS_GPS_READY).init(false).req();
        // ...
    }
}

```

### Adding Custom Types

While MonkeyHooks provides out-of-the-box wrappers for primitive types (Number, String, etc.), you can create custom contexts to safely handle project-specific data types (custom Dictionary schemas, arrays, custom classes, etc.).

Copy the `Custom Type Interface Template` found at the end of `MonkeyHooks.mc` and adapt it for your custom type (e.g., `UserProfile`).

**Implementation Example:**

```monkeyc
import Toybox.Lang;
import MonkeyHooks;

// 1. Define project-specific type
typedef UserProfile as Dictionary<String, String or Number>;

// 2. Create a dedicated context class using the template
class ProfileContext {
    private var _cx as MonkeyHooks.Context;
    function initialize(cx as MonkeyHooks.Context) { _cx = cx; }
    
    function get() as UserProfile? { return _cx.get() as UserProfile?; }
    function req() as UserProfile { 
        var val = _cx.get();
        if (val == null) { throw new Lang.InvalidValueException("MonkeyHooks: UserProfile req() failed."); }
        return val as UserProfile;
    }
    function set(val as UserProfile?) as Void { _cx.set(val); }
    function setSilent(val as UserProfile?) as Void { _cx.setSilent(val); }
    function init(val as UserProfile) as ProfileContext { _cx.init(val); return self; }
    function subscribe(listener as Lang.Method) as Void { _cx.subscribe(listener); }
    function unsubscribe(listener as Lang.Method) as Void { _cx.unsubscribe(listener); }
}

// 3. Define a dedicated hook function
function useProfile(key as Object) as ProfileContext {
    return new ProfileContext(MonkeyHooks.useArena(key));
}

```

**Usage Example:**

```monkeyc
// The compiler recognizes it as a UserProfile (Dictionary), 
// eliminating the need for `as` casting on the consumer side.
var profile = useProfile(AppState.USER_PROFILE).req();
var name = profile["name"];

```

## 📄 License

MIT License
Copyright (c) 2026 Ichimura Tomoo