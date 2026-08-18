import Toybox.Lang;
import Toybox.Graphics;
import Core.ArenaConfig;

module Core {
    module Arena {
        module LoadingUiArena {
            var _arena as ArenaImpl? = null;
            var _cxs as Dictionary<Number, ArenaConfig.Context>? = null;

            module DataType {
                typedef DataTypeDef as Number;
                enum {
                    MSG_FONT
                }
            }

            function useArena(dataType as Number) as ArenaConfig.Context {
                if (_arena == null) {
                    _arena = new ArenaImpl();
                    _cxs = ({}) as Dictionary<Number, ArenaConfig.Context>;
                }

                var cached = _cxs.get(dataType);
                if (cached != null) {
                    return cached as ArenaConfig.Context;
                }

                var getter = null;
                var setter = null;

                switch (dataType) {
                    case DataType.MSG_FONT:
                        getter = _arena.method(:getMsgFont);
                        setter = _arena.method(:setMsgFont);
                        break;
                }

                var cx = new ArenaConfig.Context(getter, setter);
                _cxs.put(dataType, cx);
                return cx;
            }

            class ArenaImpl {
                private var _msgFont as Graphics.FontType? = null;
                function getMsgFont() as Graphics.FontType? {
                    return _msgFont;
                }
                function setMsgFont(f as Graphics.FontType?) as Void {
                    _msgFont = f;
                }
            }
        }
    }
}
