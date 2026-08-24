import Toybox.Lang;

module MonkeyHooks {
    /**
     * =========================================================================
     * @warning CAUTION ON USING REFERENCE TYPES (Array & Dictionary)
     * =========================================================================
     * Garmin devices have extremely limited memory and CPU resources.
     * Please adhere to the following best practices when using these hooks:
     *
     * 1. Mutation is NOT detected by standard `.set()`
     * Monkey C uses reference equality (`!=`) for objects. If you mutate an
     * existing array (e.g., `myArray.add(1)`) and call `.set(myArray)`, the
     * UI will NOT update because the memory address is identical.
     *
     * 2. Deep copying is highly discouraged
     * Do not create new arrays/dictionaries (e.g., `slice()`) every frame just
     * to trigger `.set()`. This will cause severe memory fragmentation, leading to Out-Of-Memory (OOM) crashes.
     *
     * 3. Best Practices
     * - API Responses: Safe to use `.set()` because JSON parsing naturally
     *   provides a completely new object reference.
     * - In-place Mutation: If you must mutate elements (e.g., a cyclic buffer
     *   for graphs), use `.forceSet()` instead of `.set()`. This re-renders
     *   the UI and triggers watchers safely without allocating new memory.
     * - State Flattening: Avoid grouping multiple independent states into a
     *   single Dictionary (e.g., `config["volume"]`). Instead, split them
     *   into separate primitive hooks like `useNumber(:volume)`.
     * =========================================================================
     */

    class ArrayContext {
        private var _cx as Context;

        function initialize(cx as Context) {
            _cx = cx;
        }

        function get() as Array? {
            return _cx.get() as Array?;
        }

        function req() as Array {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Array req() failed."
                );
            }
            return val as Array;
        }

        function set(val as Array?) as Void {
            _cx.set(val);
        }

        /**
         * @brief Call this instead of `set()` when you modify elements inside
         * the array directly to ensure UI and watchers are updated.
         */
        function forceSet(val as Array?) as Void {
            _cx.forceSet(val);
        }

        function setSilent(val as Array?) as Void {
            _cx.setSilent(val);
        }

        function init(val as Array) as ArrayContext {
            _cx.init(val);
            return self;
        }

        function subscribe(listener as Lang.Method) as Void {
            _cx.subscribe(listener);
        }

        function unsubscribe(listener as Lang.Method) as Void {
            _cx.unsubscribe(listener);
        }
    }

    function useArray(key as Object) as ArrayContext {
        return new ArrayContext(useArena(key));
    }

    class DictionaryContext {
        private var _cx as Context;

        function initialize(cx as Context) {
            _cx = cx;
        }

        function get() as Dictionary? {
            return _cx.get() as Dictionary?;
        }

        function req() as Dictionary {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Dictionary req() failed."
                );
            }
            return val as Dictionary;
        }

        function set(val as Dictionary?) as Void {
            _cx.set(val);
        }

        /**
         * @brief Call this instead of `set()` when you modify key/values inside
         * the dictionary directly to ensure UI and watchers are updated.
         */
        function forceSet(val as Dictionary?) as Void {
            _cx.forceSet(val);
        }

        function setSilent(val as Dictionary?) as Void {
            _cx.setSilent(val);
        }

        function init(val as Dictionary) as DictionaryContext {
            _cx.init(val);
            return self;
        }

        function subscribe(listener as Lang.Method) as Void {
            _cx.subscribe(listener);
        }

        function unsubscribe(listener as Lang.Method) as Void {
            _cx.unsubscribe(listener);
        }
    }

    function useDictionary(key as Object) as DictionaryContext {
        return new DictionaryContext(useArena(key));
    }
}
