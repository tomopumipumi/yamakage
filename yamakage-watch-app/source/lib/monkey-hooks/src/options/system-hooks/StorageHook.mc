import Toybox.Lang;
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
                    "MonkeyHooks: StorageString req() failed."
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

    class StorageNumberContext {
        private var _cx as Context;
        private var _key as String;

        function initialize(cx as Context, key as String) {
            _cx = cx;
            _key = key;
        }

        function get() as Number? {
            var val = _cx.get();
            if (val == null) {
                val = Storage.getValue(_key);
                if (val != null) {
                    _cx.setSilent(val);
                }
            }
            return val as Number?;
        }

        function req() as Number {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: StorageNumber req() failed."
                );
            }
            return val as Number;
        }

        function set(val as Number?) as Void {
            Storage.setValue(_key, val);
            _cx.set(val);
        }

        function init(val as Number) as StorageNumberContext {
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

    function useStorageNumber(key as String) as StorageNumberContext {
        return new StorageNumberContext(useArena(key), key);
    }

    class StorageBooleanContext {
        private var _cx as Context;
        private var _key as String;

        function initialize(cx as Context, key as String) {
            _cx = cx;
            _key = key;
        }

        function get() as Boolean? {
            var val = _cx.get();
            if (val == null) {
                val = Storage.getValue(_key);
                if (val != null) {
                    _cx.setSilent(val);
                }
            }
            return val as Boolean?;
        }

        function req() as Boolean {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: StorageBoolean req() failed."
                );
            }
            return val as Boolean;
        }

        function set(val as Boolean?) as Void {
            Storage.setValue(_key, val);
            _cx.set(val);
        }

        function init(val as Boolean) as StorageBooleanContext {
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

    function useStorageBoolean(key as String) as StorageBooleanContext {
        return new StorageBooleanContext(useArena(key), key);
    }

    class StorageFloatContext {
        private var _cx as Context;
        private var _key as String;

        function initialize(cx as Context, key as String) {
            _cx = cx;
            _key = key;
        }

        function get() as Float? {
            var val = _cx.get();
            if (val == null) {
                val = Storage.getValue(_key);
                if (val != null) {
                    _cx.setSilent(val);
                }
            }
            return val as Float?;
        }

        function req() as Float {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: StorageFloat req() failed."
                );
            }
            return val as Float;
        }

        function set(val as Float?) as Void {
            Storage.setValue(_key, val);
            _cx.set(val);
        }

        function init(val as Float) as StorageFloatContext {
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

    function useStorageFloat(key as String) as StorageFloatContext {
        return new StorageFloatContext(useArena(key), key);
    }

    /**
     * =========================================================================
     * @warning CAUTION ON USING STORAGE COLLECTIONS (Array & Dictionary)
     * =========================================================================
     * 1. Storage Size Limit (~8KB)
     * Garmin devices typically limit the size of data saved under a single
     * Storage key to approximately 8KB. Attempting to save very large Arrays
     * or Dictionaries will result in an exception or silent failure.
     *
     * 2. Flash Memory Wear and Performance
     * Writing to Application.Storage is a slow operation and causes wear on
     * the device's flash memory. DO NOT use these hooks for high-frequency
     * state updates (e.g., UI animations or every GPS tick). Restrict saves
     * to infrequent events such as closing a settings menu.
     *
     * 3. Mutation and forceSet()
     * Similar to in-memory collections, Monkey C uses reference equality.
     * If you modify the contents of the collection directly (e.g., `arr.add(1)`),
     * you must use `.forceSet()` instead of `.set()` to ensure the data is
     * serialized to Storage and the UI update is triggered properly.
     * =========================================================================
     */
    class StorageArrayContext {
        private var _cx as Context;
        private var _key as String;

        function initialize(cx as Context, key as String) {
            _cx = cx;
            _key = key;
        }

        function get() as Array? {
            var val = _cx.get();
            if (val == null) {
                val = Storage.getValue(_key);
                if (val != null) {
                    _cx.setSilent(val);
                }
            }
            return val as Array?;
        }

        function req() as Array {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: StorageArray req() failed."
                );
            }
            return val as Array;
        }

        function set(val as Array?) as Void {
            Storage.setValue(_key, val);
            _cx.set(val);
        }

        /**
         * @brief Bypasses reference equality check. Use this when mutating
         * existing elements inside the Array to force a storage write and UI update.
         */
        function forceSet(val as Array?) as Void {
            Storage.setValue(_key, val);
            _cx.forceSet(val);
        }

        function init(val as Array) as StorageArrayContext {
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

    function useStorageArray(key as String) as StorageArrayContext {
        return new StorageArrayContext(useArena(key), key);
    }

    class StorageDictionaryContext {
        private var _cx as Context;
        private var _key as String;

        function initialize(cx as Context, key as String) {
            _cx = cx;
            _key = key;
        }

        function get() as Dictionary? {
            var val = _cx.get();
            if (val == null) {
                val = Storage.getValue(_key);
                if (val != null) {
                    _cx.setSilent(val);
                }
            }
            return val as Dictionary?;
        }

        function req() as Dictionary {
            var val = get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: StorageDictionary req() failed."
                );
            }
            return val as Dictionary;
        }

        function set(val as Dictionary?) as Void {
            Storage.setValue(_key, val);
            _cx.set(val);
        }

        /**
         * @brief Bypasses reference equality check. Use this when mutating
         * key/value pairs inside the Dictionary to force a storage write and UI update.
         */
        function forceSet(val as Dictionary?) as Void {
            Storage.setValue(_key, val);
            _cx.forceSet(val);
        }

        function init(val as Dictionary) as StorageDictionaryContext {
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

    function useStorageDictionary(key as String) as StorageDictionaryContext {
        return new StorageDictionaryContext(useArena(key), key);
    }
}
