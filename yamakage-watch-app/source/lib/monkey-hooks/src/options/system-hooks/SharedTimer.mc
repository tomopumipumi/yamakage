import Toybox.Lang;
import Toybox.Timer;

module MonkeyHooks {
    module SharedTimer {
        var _timer as Timer.Timer? = null;
        var _listeners as Array<Dictionary>? = null;
        var _isRunning as Boolean = false;
        var _intervalMs as Number = 100;

        class _TimerDelegate {
            function onTick() as Void {
                _triggerTick();
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
}
