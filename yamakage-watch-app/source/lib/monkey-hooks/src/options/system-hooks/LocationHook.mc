import Toybox.Lang;
import Toybox.Position;

module MonkeyHooks {
    module LocationHook {
        var _listeners as Array<Dictionary>? = null;
        var _isRunning as Boolean = false;

        class _LocationDelegate {
            function onLocation(info as Position.Info) as Void {
                _triggerLocation(info);
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
