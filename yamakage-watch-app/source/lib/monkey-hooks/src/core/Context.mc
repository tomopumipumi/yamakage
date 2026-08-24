import Toybox.Lang;

module MonkeyHooks {
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
        /**
         * @brief Forces a state update and UI render without checking reference equality.
         * Recommended for use with Arrays or Dictionaries when mutating their contents directly.
         */
        public function forceSet(value) as Void {
            _store.forceSet(_key, value);
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
