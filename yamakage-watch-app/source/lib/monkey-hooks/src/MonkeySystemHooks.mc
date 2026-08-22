import Toybox.Lang;
import Toybox.Timer;
import Toybox.Position;
import Toybox.Application.Storage;

module MonkeyHooks {
    class StorageStringContext {
        private var _cx as Context;
        private var _key as String;

        function initialize(cx as Context, key as String) {
            _cx = cx;
            _key = key;
        }

        function get() as String? {
            var val = _cx.get();
            if (val == null) {
                val = Storage.getValue(_key);
                if (val != null) {
                    _cx.setSilent(val);
                }
            }
            return val as String?;
        }

        function req() as String {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Storage req() failed."
                );
            }
            return val as String;
        }

        function set(val as String?) as Void {
            Storage.setValue(_key, val);
            _cx.set(val);
        }

        function init(val as String) as StorageStringContext {
            var existing = Storage.getValue(_key);
            if (existing == null) {
                Storage.setValue(_key, val);
                _cx.init(val);
            } else {
                _cx.init(existing);
            }
            return self;
        }
    }
    function useStorageString(key as String) as StorageStringContext {
        return new StorageStringContext(useArena(key), key);
    }

    module SharedTimer {
        var _timer as Timer.Timer? = null;
        var _listeners as Array<Dictionary>? = null;
        var _isRunning as Boolean = false;
        var _intervalMs as Number = 100;

        class _TimerDelegate {
            function onTick() as Void {
                MonkeyHooks.SharedTimer._triggerTick();
            }
        }
        var _delegate = new _TimerDelegate();

        function setInterval(ms as Number) as Void {
            _intervalMs = ms;
            if (_isRunning && _timer != null) {
                (_timer as Timer.Timer).stop();
                (_timer as Timer.Timer).start(
                    _delegate.method(:onTick),
                    _intervalMs,
                    true
                );
            }
        }

        function subscribe(target as Object, methodSymbol as Symbol) as Void {
            if (_listeners == null) {
                _listeners = [] as Array<Dictionary>;
            }

            var found = false;
            for (var i = 0; i < _listeners.size(); i++) {
                var l = _listeners[i] as Dictionary;
                if (l[:weakRef].get() == target && l[:symbol] == methodSymbol) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                _listeners.add({
                    :weakRef => target.weak(),
                    :symbol => methodSymbol
                });
            }

            if (!_isRunning && _listeners.size() > 0) {
                if (_timer == null) {
                    _timer = new Timer.Timer();
                }
                (_timer as Timer.Timer).start(
                    _delegate.method(:onTick),
                    _intervalMs,
                    true
                );
                _isRunning = true;
            }
        }

        function unsubscribe(target as Object, methodSymbol as Symbol) as Void {
            if (_listeners != null) {
                for (var i = _listeners.size() - 1; i >= 0; i--) {
                    var l = _listeners[i] as Dictionary;
                    var obj = l[:weakRef].get();

                    if (
                        obj == null ||
                        (obj == target && l[:symbol] == methodSymbol)
                    ) {
                        _listeners.remove(l);
                    }
                }
                if (_listeners.size() == 0 && _isRunning) {
                    (_timer as Timer.Timer).stop();
                    _isRunning = false;
                }
            }
        }

        function _triggerTick() as Void {
            if (_listeners != null) {
                for (var i = _listeners.size() - 1; i >= 0; i--) {
                    var l = _listeners[i] as Dictionary;
                    var obj = l[:weakRef].get();

                    if (obj != null) {
                        if (obj has l[:symbol]) {
                            obj.method(l[:symbol]).invoke();
                        }
                    } else {
                        _listeners.remove(l);
                    }
                }
                if (_listeners.size() == 0 && _isRunning) {
                    (_timer as Timer.Timer).stop();
                    _isRunning = false;
                }
            }
        }
    }

    module LocationHook {
        var _listeners as Array<Dictionary>? = null;
        var _isRunning as Boolean = false;

        class _LocationDelegate {
            function onLocation(info as Position.Info) as Void {
                MonkeyHooks.LocationHook._triggerLocation(info);
            }
        }
        var _delegate = new _LocationDelegate();

        function subscribe(target as Object, methodSymbol as Symbol) as Void {
            if (_listeners == null) {
                _listeners = [] as Array<Dictionary>;
            }

            var found = false;
            for (var i = 0; i < _listeners.size(); i++) {
                var l = _listeners[i] as Dictionary;
                if (l[:weakRef].get() == target && l[:symbol] == methodSymbol) {
                    found = true;
                    break;
                }
            }

            if (!found) {
                _listeners.add({
                    :weakRef => target.weak(),
                    :symbol => methodSymbol
                });
            }

            if (!_isRunning && _listeners.size() > 0) {
                Position.enableLocationEvents(
                    Position.LOCATION_CONTINUOUS,
                    _delegate.method(:onLocation)
                );
                _isRunning = true;
            }
        }

        function unsubscribe(target as Object, methodSymbol as Symbol) as Void {
            if (_listeners != null) {
                for (var i = _listeners.size() - 1; i >= 0; i--) {
                    var l = _listeners[i] as Dictionary;
                    var obj = l[:weakRef].get();

                    if (
                        obj == null ||
                        (obj == target && l[:symbol] == methodSymbol)
                    ) {
                        _listeners.remove(l);
                    }
                }
                if (_listeners.size() == 0 && _isRunning) {
                    Position.enableLocationEvents(
                        Position.LOCATION_DISABLE,
                        _delegate.method(:onLocation)
                    );
                    _isRunning = false;
                }
            }
        }

        function _triggerLocation(info as Position.Info) as Void {
            if (_listeners != null) {
                for (var i = _listeners.size() - 1; i >= 0; i--) {
                    var l = _listeners[i] as Dictionary;
                    var obj = l[:weakRef].get();

                    if (obj != null) {
                        if (obj has l[:symbol]) {
                            obj.method(l[:symbol]).invoke(info);
                        }
                    } else {
                        _listeners.remove(l);
                    }
                }
                if (_listeners.size() == 0 && _isRunning) {
                    Position.enableLocationEvents(
                        Position.LOCATION_DISABLE,
                        _delegate.method(:onLocation)
                    );
                    _isRunning = false;
                }
            }
        }
    }
}
