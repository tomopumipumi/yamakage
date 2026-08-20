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
        var _listeners as Array<Lang.Method>? = null;
        var _isRunning as Boolean = false;

        class _TimerDelegate {
            function onTick() as Void {
                MonkeyHooks.SharedTimer._triggerTick();
            }
        }
        var _delegate = new _TimerDelegate();

        function subscribe(listener as Lang.Method) as Void {
            if (_listeners == null) {
                _listeners = [] as Array<Lang.Method>;
            }

            if (_listeners.indexOf(listener) == -1) {
                _listeners.add(listener);
            }

            if (!_isRunning && _listeners.size() > 0) {
                if (_timer == null) {
                    _timer = new Timer.Timer();
                }
                (_timer as Timer.Timer).start(
                    _delegate.method(:onTick),
                    100,
                    true
                );
                _isRunning = true;
            }
        }

        function unsubscribe(listener as Lang.Method) as Void {
            if (_listeners != null) {
                _listeners.remove(listener);
                if (_listeners.size() == 0 && _isRunning) {
                    _timer.stop();
                    _isRunning = false;
                }
            }
        }

        function _triggerTick() as Void {
            if (_listeners != null) {
                for (var i = 0; i < _listeners.size(); i++) {
                    var listener = _listeners[i] as Lang.Method;
                    listener.invoke();
                }
            }
        }
    }

    module LocationHook {
        var _listeners as Array<Lang.Method>? = null;
        var _isRunning as Boolean = false;

        class _LocationDelegate {
            function onLocation(info as Position.Info) as Void {
                MonkeyHooks.LocationHook._triggerLocation(info);
            }
        }
        var _delegate = new _LocationDelegate();

        function subscribe(listener as Lang.Method) as Void {
            if (_listeners == null) {
                _listeners = [] as Array<Lang.Method>;
            }

            if (_listeners.indexOf(listener) == -1) {
                _listeners.add(listener);
            }

            if (!_isRunning && _listeners.size() > 0) {
                Position.enableLocationEvents(
                    Position.LOCATION_CONTINUOUS,
                    _delegate.method(:onLocation)
                );
                _isRunning = true;
            }
        }

        function unsubscribe(listener as Lang.Method) as Void {
            if (_listeners != null) {
                _listeners.remove(listener);
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
                for (var i = 0; i < _listeners.size(); i++) {
                    var listener = _listeners[i] as Lang.Method;
                    listener.invoke(info);
                }
            }
        }
    }
}
