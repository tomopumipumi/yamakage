import Toybox.Lang;
import Toybox.Graphics;

module MonkeyHooks {
    var _globalStore as Store? = null;

    function getStore() as Store {
        if (_globalStore == null) {
            _globalStore = new Store();
        }
        return _globalStore as Store;
    }

    function useArena(key as Object) as Context {
        return new Context(getStore(), key);
    }
    function destroy(key as Object) as Void {
        getStore().destroy(key);
    }

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

    class FontContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Graphics.FontType? {
            return _cx.get() as Graphics.FontType?;
        }
        function req() as Graphics.FontType {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Font req() failed."
                );
            }
            return val as Graphics.FontType;
        }
        function set(val as Graphics.FontType?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Graphics.FontType?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Graphics.FontType) as FontContext {
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
    function useFont(key as Object) as FontContext {
        return new FontContext(useArena(key));
    }

    class ColorContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Graphics.ColorType? {
            return _cx.get() as Graphics.ColorType?;
        }
        function req() as Graphics.ColorType {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Color req() failed."
                );
            }
            return val as Graphics.ColorType;
        }
        function set(val as Graphics.ColorType?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Graphics.ColorType?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Graphics.ColorType) as ColorContext {
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
    function useColor(key as Object) as ColorContext {
        return new ColorContext(useArena(key));
    }

    class ArrayBufferContext {
        private var _cx as Context;
        private var _size as Number;

        function initialize(cx as Context, size as Number) {
            _cx = cx;
            _size = size;
        }

        function req() as Array<Number or Float> {
            var val = _cx.get();
            if (val == null) {
                val = new [_size] as Array<Number or Float>;
                for (var i = 0; i < _size; i++) {
                    val[i] = 0.0;
                }
                _cx.setSilent(val);
            }
            return val as Array<Number or Float>;
        }
    }

    function useArrayBuffer(
        key as Object,
        size as Number
    ) as ArrayBufferContext {
        return new ArrayBufferContext(useArena(key), size);
    }

    class PolygonBufferContext {
        private var _cx as Context;
        private var _size as Number;

        function initialize(cx as Context, size as Number) {
            _cx = cx;
            _size = size;
        }

        function req() as Array<[Lang.Numeric, Lang.Numeric]> {
            var val = _cx.get();
            if (val == null) {
                val = new [_size] as Array<[Lang.Numeric, Lang.Numeric]>;
                for (var i = 0; i < _size; i++) {
                    val[i] = [0.0, 0.0] as [Lang.Numeric, Lang.Numeric];
                }
                _cx.setSilent(val);
            }
            return val as Array<[Lang.Numeric, Lang.Numeric]>;
        }
    }
    function usePolygonBuffer(
        key as Object,
        numVertices as Number
    ) as PolygonBufferContext {
        return new PolygonBufferContext(useArena(key), numVertices);
    }
}
