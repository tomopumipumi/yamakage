import Toybox.Lang;
import Toybox.WatchUi;

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

    class Context {
        protected var _store as Store;
        protected var _key as Object;

        function initialize(store as Store, key as Object) {
            _store = store;
            _key = key;
        }

        public function init(initialValue) as Context {
            _store.init(_key, initialValue);
            return self;
        }
        public function get() {
            return _store.get(_key);
        }
        public function set(value) as Void {
            _store.set(_key, value);
        }
        public function setSilent(value) as Void {
            _store.setSilent(_key, value);
        }
        public function subscribe(listener as Lang.Method) as Void {
            _store.subscribe(_key, listener);
        }
        public function unsubscribe(listener as Lang.Method) as Void {
            _store.unsubscribe(_key, listener);
        }
    }
}
