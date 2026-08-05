import Toybox.Graphics;
import Toybox.Lang;
import Hal.Strings;
import Core.DataArena.UiArena.ContentsPositionArena;

module Ui {
    module FontManager {
        typedef FontSetType as Array<Graphics.FontType>;

        module FontSet {
            enum {
                STATUS_ICON_FONT,
                STATUS_FONT,
                EVENT_TIME_FONT,
                EVENT_ICON_FONT,
                WATERMARK_FONT,
                DATA_SIZE
            }
        }

        const NORMAL_FONTS = [
            Graphics.FONT_MEDIUM,
            Graphics.FONT_SMALL,
            Graphics.FONT_TINY,
            Graphics.FONT_XTINY
        ];

        const TIME_FONTS = [
            Graphics.FONT_NUMBER_HOT,
            Graphics.FONT_NUMBER_MEDIUM,
            Graphics.FONT_NUMBER_MILD,
            Graphics.FONT_LARGE,
            Graphics.FONT_MEDIUM,
            Graphics.FONT_SMALL,
            Graphics.FONT_TINY,
            Graphics.FONT_XTINY
        ];

        function calculateFonts(
            dc as Graphics.Dc,
            loadedIconFonts as Array<Graphics.FontType>
        ) as FontSetType {
            var fontSet = new [FontSet.DATA_SIZE];

            var sWidth = PositionConfigure.contentWidth;
            var sHeight = PositionConfigure.safeHeight;
            var isCompact = ContentsPositionArena.isCompactMode;

            var statusMaxWidth = (
                sWidth * (isCompact ? 0.85 : 0.95)
            ).toNumber();
            var statusMaxHeight = (
                sHeight * (isCompact ? 0.15 : 0.25)
            ).toNumber();

            var eventRowMaxWidth = (
                sWidth * (isCompact ? 0.65 : 0.75)
            ).toNumber();
            var eventRowMaxHeight = (
                sHeight * (isCompact ? 0.2 : 0.35)
            ).toNumber();

            var iconMaxWidth = (sWidth * 0.3).toNumber();

            var watermarkMaxWidth = (sWidth * 0.8).toNumber();
            var watermarkMaxHeight = (
                sHeight * (isCompact ? 0.15 : 0.2)
            ).toNumber();

            var statusFont = FontCalculator.findBestFont(
                dc,
                "次回更新: 59:59", // Dummy Text
                statusMaxWidth,
                statusMaxHeight,
                NORMAL_FONTS
            );
            fontSet[FontSet.STATUS_FONT] = statusFont;

            var statusTextHeight = dc.getFontHeight(statusFont);
            var statusIconMaxHeight = (statusTextHeight * 1.3).toNumber();

            fontSet[FontSet.EVENT_TIME_FONT] = FontCalculator.findBestFont(
                dc,
                "88:88",
                eventRowMaxWidth,
                eventRowMaxHeight,
                TIME_FONTS
            );

            fontSet[FontSet.STATUS_ICON_FONT] = FontCalculator.findBestFont(
                dc,
                Ui.Icons.ICON_CONNECTING,
                iconMaxWidth,
                statusIconMaxHeight,
                loadedIconFonts
            );

            fontSet[FontSet.EVENT_ICON_FONT] = FontCalculator.findBestFont(
                dc,
                Ui.Icons.ICON_SUNRISE,
                iconMaxWidth,
                eventRowMaxHeight,
                loadedIconFonts
            );

            fontSet[FontSet.WATERMARK_FONT] = FontCalculator.findBestFont(
                dc,
                Strings.getAppTitle(),
                watermarkMaxWidth,
                watermarkMaxHeight,
                NORMAL_FONTS
            );

            return fontSet;
        }

        module FontCalculator {
            function findBestFont(
                dc as Graphics.Dc,
                dummyText as String,
                maxWidth as Number,
                maxHeight as Number,
                candidates as Array<Graphics.FontType>
            ) as Graphics.FontType {
                var candidatesSize = candidates.size();
                var font = candidates[candidatesSize - 1];

                for (var i = 0; i < candidatesSize; i++) {
                    font = candidates[i];
                    var dim = dc.getTextDimensions(dummyText, font);
                    if (dim[0] <= maxWidth && dim[1] <= maxHeight) {
                        return font;
                    }
                }
                return font;
            }
        }
    }
}
