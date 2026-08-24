import Toybox.Lang;
import Toybox.Graphics;

module MonkeyHooks {
    class NumberContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Number? {
            return _cx.get() as Number?;
        }
        function req() as Number {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Number req() failed."
                );
            }
            return val as Number;
        }
        function set(val as Number?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Number?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Number) as NumberContext {
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
    function useNumber(key as Object) as NumberContext {
        return new NumberContext(useArena(key));
    }

    class StringContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as String? {
            return _cx.get() as String?;
        }
        function req() as String {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: String req() failed."
                );
            }
            return val as String;
        }
        function set(val as String?) as Void {
            _cx.set(val);
        }
        function setSilent(val as String?) as Void {
            _cx.setSilent(val);
        }
        function init(val as String) as StringContext {
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
    function useString(key as Object) as StringContext {
        return new StringContext(useArena(key));
    }

    class BooleanContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Boolean? {
            return _cx.get() as Boolean?;
        }
        function req() as Boolean {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Boolean req() failed."
                );
            }
            return val as Boolean;
        }
        function set(val as Boolean?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Boolean?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Boolean) as BooleanContext {
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
    function useBoolean(key as Object) as BooleanContext {
        return new BooleanContext(useArena(key));
    }

    class FloatContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Float? {
            return _cx.get() as Float?;
        }
        function req() as Float {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Float req() failed."
                );
            }
            return val as Float;
        }
        function set(val as Float?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Float?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Float) as FloatContext {
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
    function useFloat(key as Object) as FloatContext {
        return new FloatContext(useArena(key));
    }

    class LongContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Long? {
            return _cx.get() as Long?;
        }
        function req() as Long {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Long req() failed."
                );
            }
            return val as Long;
        }
        function set(val as Long?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Long?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Long) as LongContext {
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
    function useLong(key as Object) as LongContext {
        return new LongContext(useArena(key));
    }

    class DoubleContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Double? {
            return _cx.get() as Double?;
        }
        function req() as Double {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Double req() failed."
                );
            }
            return val as Double;
        }
        function set(val as Double?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Double?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Double) as DoubleContext {
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
    function useDouble(key as Object) as DoubleContext {
        return new DoubleContext(useArena(key));
    }

    class SymbolContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Symbol? {
            return _cx.get() as Symbol?;
        }
        function req() as Symbol {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Symbol req() failed."
                );
            }
            return val as Symbol;
        }
        function set(val as Symbol?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Symbol?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Symbol) as SymbolContext {
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
    function useSymbol(key as Object) as SymbolContext {
        return new SymbolContext(useArena(key));
    }

    class CharContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Char? {
            return _cx.get() as Char?;
        }
        function req() as Char {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Char req() failed."
                );
            }
            return val as Char;
        }
        function set(val as Char?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Char?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Char) as CharContext {
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
    function useChar(key as Object) as CharContext {
        return new CharContext(useArena(key));
    }
}
