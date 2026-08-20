import Toybox.Lang;

module MonkeyHooks {
    class WatchContext {
        private var _store as Store;
        private var _deps as Array<Object>;
        private var _callback as Lang.Method;
        private var _boundMethod as Lang.Method;

        function initialize(
            store as Store,
            deps as Array<Object>,
            callback as Lang.Method
        ) {
            _store = store;
            _deps = deps;
            _callback = callback;
            _boundMethod = method(:_onStateChanged);

            for (var i = 0; i < deps.size(); i++) {
                _store.subscribe(deps[i], _boundMethod);
            }
        }

        function destroy() as Void {
            for (var i = 0; i < _deps.size(); i++) {
                _store.unsubscribe(_deps[i], _boundMethod);
            }
        }

        function _onStateChanged(changedValue) as Void {
            var size = _deps.size();
            var currentValues = new [size];
            for (var i = 0; i < size; i++) {
                currentValues[i] = _store.get(_deps[i]);
            }
            _callback.invoke(currentValues);
        }
    }

    function useWatch(
        deps as Array<Object>,
        callback as Lang.Method
    ) as WatchContext {
        return new WatchContext(getStore(), deps, callback);
    }
}
