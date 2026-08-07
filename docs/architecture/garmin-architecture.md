# Garmin App Architecture (YAMAKAGE)

This document defines the internal architecture, module structure, and responsive UI rendering logic of the Garmin Connect IQ app "YAMAKAGE".

## 1. Module Structure and Dependencies

To avoid direct dependency on Garmin's `Toybox` API and to enhance testability and maintainability, a layered architecture is adopted.

```mermaid
flowchart TD
    classDef entry fill:#f87171,stroke:#b91c1c,stroke-width:2px,color:#fff
    classDef ui fill:#fbbf24,stroke:#b45309,stroke-width:2px,color:#fff
    classDef system fill:#34d399,stroke:#047857,stroke-width:2px,color:#fff
    classDef hal fill:#60a5fa,stroke:#047857,stroke-width:2px,color:#fff
    classDef core fill:#818cf8,stroke:#1d4ed8,stroke-width:2px,color:#fff
    classDef toybox fill:#e5e7eb,color:#000,stroke:#6b7280,stroke-width:2px,stroke-dasharray: 5 5

    subgraph Entrypoints ["Entrypoints"]
        App[YamakageApp]:::entry
        View[YamakageView]:::entry
        Bg[YamakageBackground]:::entry
    end

    subgraph UI ["UI Layer (source/ui)"]
        ViewLogic[ViewLogic<br/>Determines display text from state]:::ui
        PosConfig[PositionConfigure<br/>Calculates safe area]:::ui
        FontMgr[FontManager<br/>Dynamically calculates optimal font]:::ui
        Comp[Components<br/>Component rendering]:::ui
    end

    subgraph Systems ["Systems Layer (source/systems)"]
        LatLon[LatLonSystem<br/>Formats GPS coordinates]:::system
        Time[TimeSystem<br/>Converts UnixTime]:::system
        Crypt[Crypt<br/>Generates session ID]:::system
    end

    subgraph HAL ["HAL: Hardware Abstraction (source/hal)"]
        Storage[LocalStorage<br/>Inter-process data sharing]:::hal
        Device[Device<br/>Retrieves device info]:::hal
        Strings[Strings / Icons<br/>Loads resources]:::hal
    end

    subgraph Core ["Core Layer (source/core)"]
        DataArena[DataArena<br/>In-memory state management]:::core
        Schema[ApiSchema<br/>Data type definitions]:::core
    end

    subgraph OS ["Garmin Connect IQ"]
        Toybox[Toybox API]:::toybox
    end

    View --> UI
    Bg --> Systems
    Bg --> HAL
    UI --> Core
    UI --> HAL
    UI --> Systems
    Systems --> HAL
    HAL --> Toybox


```

### Design Philosophy

- **HAL (Hardware Abstraction Layer)**: Wraps the standard Garmin `Toybox` API instead of calling it directly from the UI layer. This absorbs OS version differences and facilitates unit testing using mocks (testing without a simulator).
- **DataArena (Core)**: Defines `DataArena` as a singleton-like store for stateful information, such as UI rendering coordinates and strings, separating calculation logic from rendering logic. While a design providing state-mutating closures (like React) is typically safer, direct modifications are permitted to eliminate function call overhead.

---

## 2. Inter-Process Data Flow (Foreground / Background)

In Garmin Data Field apps, external communication (HTTP) can only be executed in a background process (Temporal Event). This section illustrates how API data fetched in the background is passed to the main app's (foreground) UI.

```mermaid
sequenceDiagram
    participant OS as Garmin OS
    participant App as YamakageApp<br/>(Main Process)
    participant Storage as Application.Storage
    participant Bg as YamakageBackground<br/>(Bg Process)
    participant API as YAMAKAGE API

    App->>OS: onStart: Register TemporalEvent (Min 5-min intervals)
    
    Note over OS, Bg: --- Trigger Background Process ---
    OS->>Bg: onTemporalEvent()
    Bg->>Storage: Retrieve Session ID
    Bg->>API: makeWebRequest()
    API-->>Bg: 200 OK (Array Data)
    Bg->>OS: Background.exit(data)

    Note over OS, App: --- Return to Foreground ---
    OS->>App: onBackgroundData(data)
    App->>Storage: Persist Fetched Data (SHADOW_DATA_KEY)
    App->>Storage: Record Last Sync Time
    App->>OS: WatchUi.requestUpdate() (Request UI Redraw)

    Note over App, Storage: --- Rendering Process (Per Second) ---
    App->>Storage: getShadowData()
    App->>App: Calculate Countdown for Remaining Time
    App->>OS: Render Screen


```

### Design Highlights

- Data is passed from the background process to the main process by supplying it as an argument to `Background.exit()`, receiving it in `onBackgroundData()`, and then writing it to `Application.Storage`.
- Even during communication errors, an `error` object is passed and recorded in Storage. This ensures the main UI correctly displays states like "Communicating" or "Update Failed".

---

## 3. Responsive UI Calculation Logic

Garmin devices come in various screen shapes, including circular, rectangular, and partially obscured. Instead of using fixed XML layouts, YAMAKAGE adopts a **code-based logic that dynamically calculates safe areas and fonts**.

```mermaid
flowchart TD
    Start[onLayout: Get Device Screen Size<br/>width, height] --> Flag[Get Screen Shape and Obscure Flags<br/>Is it round? Where is it cut off?]
    
    Flag --> Safe[PositionConfigure.calculateSafeArea<br/>Calculate margins and determine 'Safe Area']
    
    Safe --> Compact{Safe Area Height < 100px <br/> OR Width < 140px ?}
    
    Compact -- Yes --> ModeC[isCompactMode = true<br/>Condense UI proportions]
    Compact -- No --> ModeN[isCompactMode = false<br/>Normal proportions]
    
    ModeC --> Pos[Calculate X, Y coordinates for elements<br/>StatusBar, EventRow, Watermark]
    ModeN --> Pos
    
    Pos --> Font[FontManager.findBestFont<br/>Loop candidate fonts from largest to smallest]
    
    Font --> Check{Does dummy text<br/>fit within the<br/>calculated bounds?}
    
    Check -- No (Overflows) --> FontDown[Try the next smaller font]
    FontDown --> Check
    
    Check -- Yes (Fits) --> FontSet[Determine and cache optimal font]
    
    FontSet --> Draw[onUpdate: Render using determined coordinates and font]

```

### Reasons for Adopting Dynamic Calculations

* Using XML layouts (`layout.xml`) would require maintaining finely-tuned layout definitions for hundreds of different Garmin devices, resulting in poor maintainability.
* With this dynamic approach, the app calculates the maximum usable area based on the screen size and automatically selects the largest font that doesn't overflow. This design ensures that **the optimal layout is automatically applied even when new device models are released, without requiring code changes**.