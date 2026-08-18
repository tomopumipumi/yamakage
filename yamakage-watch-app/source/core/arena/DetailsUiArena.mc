import Toybox.Lang;
import Toybox.Graphics;
import Core.ArenaConfig;

module Core {
    module Arena {
        module DetailsUiArena {
            var _arena as ArenaImpl? = null;
            var _cxs as Dictionary<Number, ArenaConfig.Context>? = null;

            module DataType {
                typedef DataTypeDef as Number;
                enum {
                    LABEL_FONT,
                    VALUE_FONT,
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
                    case DataType.LABEL_FONT:
                        getter = _arena.method(:getLabelFont);
                        setter = _arena.method(:setLabelFont);
                        break;
                    case DataType.VALUE_FONT:
                        getter = _arena.method(:getValueFont);
                        setter = _arena.method(:setValueFont);
                        break;
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
                private var _labelFont as Graphics.FontType? = null;
                private var _valueFont as Graphics.FontType? = null;
                private var _iconFont as Graphics.FontType? = null;
                function getLabelFont() as Graphics.FontType? {
                    return _labelFont;
                }
                function setLabelFont(f as Graphics.FontType?) as Void {
                    _labelFont = f;
                }
                function getValueFont() as Graphics.FontType? {
                    return _valueFont;
                }
                function setValueFont(f as Graphics.FontType?) as Void {
                    _valueFont = f;
                }
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
