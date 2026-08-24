import Toybox.Lang;
import Toybox.Graphics;

module MonkeyHooks {
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
