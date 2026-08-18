import Toybox.Lang;
import Toybox.Graphics;
import Core.ArenaConfig;

module Core {
    module Arena {
        module MainUiArena {
            var _arena as ArenaImpl? = null;
            var _cxs as Dictionary<Number, ArenaConfig.Context>? = null;

            module DataType {
                typedef DataTypeDef as Number;
                enum {
                    TITLE_FONT,
                    BTN_FONT,
                    BTN_WIDTH,
                    BTN_HEIGHT
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
                    case DataType.TITLE_FONT:
                        getter = _arena.method(:getTitleFont);
                        setter = _arena.method(:setTitleFont);
                        break;
                    case DataType.BTN_FONT:
                        getter = _arena.method(:getBtnFont);
                        setter = _arena.method(:setBtnFont);
                        break;
                    case DataType.BTN_WIDTH:
                        getter = _arena.method(:getBtnWidth);
                        setter = _arena.method(:setBtnWidth);
                        break;
                    case DataType.BTN_HEIGHT:
                        getter = _arena.method(:getBtnHeight);
                        setter = _arena.method(:setBtnHeight);
                        break;
                }

                var cx = new ArenaConfig.Context(getter, setter);
                _cxs.put(dataType, cx);
                return cx;
            }

            class ArenaImpl {
                private var _titleFont as Graphics.FontType? = null;
                private var _btnFont as Graphics.FontType? = null;
                private var _btnWidth as Number = 0;
                private var _btnHeight as Number = 0;

                function getTitleFont() as Graphics.FontType? {
                    return _titleFont;
                }
                function setTitleFont(f as Graphics.FontType?) as Void {
                    _titleFont = f;
                }
                function getBtnFont() as Graphics.FontType? {
                    return _btnFont;
                }
                function setBtnFont(f as Graphics.FontType?) as Void {
                    _btnFont = f;
                }
                function getBtnWidth() as Number {
                    return _btnWidth;
                }
                function setBtnWidth(w as Number) as Void {
                    _btnWidth = w;
                }
                function getBtnHeight() as Number {
                    return _btnHeight;
                }
                function setBtnHeight(h as Number) as Void {
                    _btnHeight = h;
                }
            }
        }
    }
}
