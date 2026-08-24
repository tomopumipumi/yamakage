import Toybox.Lang;

module MonkeyHooks {
    class ComputedContext {
        private var _store as Store;
        private var _targetKey as Object;
        private var _deps as Array<Object>;
        private var _computeMethod as Lang.Method;
        private var _lastDepsValues as Array?;

        function initialize(
            store as Store,
            targetKey as Object,
            deps as Array<Object>,
            computeMethod as Lang.Method
        ) {
            _store = store;
            _targetKey = targetKey;
            _deps = deps;
            _computeMethod = computeMethod;
            _lastDepsValues = null;
        }

        function get() {
            var size = _deps.size();
            var currentDeps = new [size];
            var isChanged = false;

            for (var i = 0; i < size; i++) {
                currentDeps[i] = _store.get(_deps[i]);
                if (
                    _lastDepsValues == null ||
                    _lastDepsValues[i] != currentDeps[i]
                ) {
                    isChanged = true;
                }
            }

            if (isChanged || _store.get(_targetKey) == null) {
                var result = _computeMethod.invoke(currentDeps);
                _store.setSilent(_targetKey, result);
                _lastDepsValues = currentDeps;
            }
            return _store.get(_targetKey);
        }

        function req() {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Computed req() failed."
                );
            }
            return val;
        }
    }

    function useComputed(
        targetKey as Object,
        deps as Array<Object>,
        computeMethod as Lang.Method
    ) as ComputedContext {
        return new ComputedContext(getStore(), targetKey, deps, computeMethod);
    }
}
