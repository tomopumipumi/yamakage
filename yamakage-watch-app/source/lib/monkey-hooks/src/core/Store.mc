import Toybox.Lang;

module MonkeyHooks {
    class Store {
        private var _state as Dictionary;
        private var _listeners as Dictionary;

        function initialize() {
            _state = {};
            _listeners = {};
        }

        function get(key as Object) {
            return _state.get(key);
        }

        function init(key as Object, initValue) as Void {
            if (_state.get(key) == null) {
                _state.put(key, initValue);
            }
        }

        function set(key as Object, value) as Void {
            var currentValue = _state.get(key);
            if (currentValue != value) {
                _state.put(key, value);
                WatchUi.requestUpdate();

                var list = _listeners.get(key) as Array<Lang.Method>?;
                if (list != null) {
                    for (var i = 0; i < list.size(); i++) {
                        var listener = list[i] as Lang.Method;
                        listener.invoke(value);
                    }
                }

                if (MonkeyHooks has :_triggerWatchers) {
                    MonkeyHooks._triggerWatchers();
                }
            }
        }

        /**
         * @brief Bypasses the reference equality check (`!=`) and forces a state update.
         * Useful when mutating an existing array or dictionary where the memory address
         * remains the same, but the internal elements have changed.
         */
        function forceSet(key as Object, value) as Void {
            _state.put(key, value);
            WatchUi.requestUpdate();

            var list = _listeners.get(key) as Array<Lang.Method>?;
            if (list != null) {
                for (var i = 0; i < list.size(); i++) {
                    var listener = list[i] as Lang.Method;
                    listener.invoke(value);
                }
            }

            if (MonkeyHooks has :_triggerWatchers) {
                MonkeyHooks._triggerWatchers();
            }
        }

        function setSilent(key as Object, value) as Void {
            _state.put(key, value);
        }

        function subscribe(key as Object, listener as Lang.Method) as Void {
            var list = _listeners.get(key) as Array<Lang.Method>?;
            if (list == null) {
                list = [] as Array<Lang.Method>;
                _listeners.put(key, list);
            }
            list.add(listener);
        }

        function unsubscribe(key as Object, listener as Lang.Method) as Void {
            var list = _listeners.get(key) as Array<Lang.Method>?;
            if (list != null) {
                list.remove(listener);
            }
        }

        function destroy(key as Object) as Void {
            _state.remove(key);
            _listeners.remove(key);
        }
    }
}
