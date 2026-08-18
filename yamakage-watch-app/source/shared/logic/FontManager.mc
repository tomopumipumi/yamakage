import Toybox.Graphics;
import Toybox.Lang;

module Shared {
    module Logic {
        module FontManager {
            const NORMAL_FONTS =
                [
                    Graphics.FONT_LARGE,
                    Graphics.FONT_MEDIUM,
                    Graphics.FONT_SMALL,
                    Graphics.FONT_TINY,
                    Graphics.FONT_XTINY
                ] as Array<Graphics.FontType>;

            function findBestFont(
                dc as Graphics.Dc,
                dummyText as String,
                maxWidth as Number,
                maxHeight as Number
            ) as Graphics.FontType {
                var font = NORMAL_FONTS[NORMAL_FONTS.size() - 1];

                for (var i = 0; i < NORMAL_FONTS.size(); i++) {
                    var f = NORMAL_FONTS[i];
                    var dim = dc.getTextDimensions(dummyText, f);
                    if (dim[0] <= maxWidth && dim[1] <= maxHeight) {
                        return f;
                    }
                }
                return font;
            }

            function findBestFontFromList(
                dc as Graphics.Dc,
                dummyText as String,
                maxWidth as Number,
                maxHeight as Number,
                fontList as Array<Graphics.FontType>
            ) as Graphics.FontType {
                var fallbackFont = fontList[0];

                for (var i = fontList.size() - 1; i >= 0; i--) {
                    var f = fontList[i];
                    var dim = dc.getTextDimensions(dummyText, f);
                    if (dim[0] <= maxWidth && dim[1] <= maxHeight) {
                        return f;
                    }
                }

                return fallbackFont;
            }
        }
    }
}
