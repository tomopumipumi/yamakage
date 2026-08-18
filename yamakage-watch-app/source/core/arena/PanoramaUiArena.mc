import Toybox.Lang;
import Toybox.Graphics;
import Core.ArenaConfig;

module Core {
    module Arena {
        module PanoramaUiArena {
            var _arena as ArenaImpl? = null;
            var _cxs as Dictionary<Number, ArenaConfig.Context>? = null;

            module DataType {
                typedef DataTypeDef as Number;
                enum {
                    ICON_FONT
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
                    case DataType.ICON_FONT:
                        getter = _arena.method(:getIconFont);
                        setter = _arena.method(:setIconFont);
                        break;
                }

                var cx = new ArenaConfig.Context(getter, setter);
                _cxs.put(dataType, cx);
                return cx;
            }

            class ArenaImpl {
                private var _iconFont as Graphics.FontType? = null;

                function getIconFont() as Graphics.FontType? {
                    return _iconFont;
                }
                function setIconFont(f as Graphics.FontType?) as Void {
                    _iconFont = f;
                }
            }
        }
    }
}
