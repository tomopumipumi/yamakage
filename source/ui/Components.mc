import Toybox.Lang;
import Toybox.Graphics;
import Core.DataArena.UiArena.ContentsPositionArena;
import Core.DataArena.UiArena.ContentsPositionArena.StatusBarArena;
import Core.DataArena.UiArena.ContentsPositionArena.EventRowArena;
import Core.DataArena.UiArena.ContentsPositionArena.WatermarkArena;

module Ui {
    module Components {
        function drawStatusBar(
            dc as Graphics.Dc,
            timeStr as String,
            isFailed as Boolean,
            subColor as Number,
            textFont as Graphics.FontType,
            iconFont as Graphics.FontType
        ) as Void {
            dc.setColor(
                isFailed ? Graphics.COLOR_RED : subColor,
                Graphics.COLOR_TRANSPARENT
            );

            var isCompact = ContentsPositionArena.isCompactMode;

            if (isFailed || isCompact || timeStr.length() > 5) {
                dc.drawText(
                    StatusBarArena.labelX,
                    StatusBarArena.labelY,
                    textFont,
                    timeStr,
                    StatusBarArena.labelJustify
                );
            } else {
                var iconWidth = dc.getTextWidthInPixels(
                    Ui.Icons.ICON_CONNECTING,
                    iconFont
                );
                var textWidth = dc.getTextWidthInPixels(timeStr, textFont);
                var totalWidth = iconWidth + textWidth + 5; // 5 is margin
                var startX = StatusBarArena.labelX - totalWidth / 2;

                dc.drawText(
                    startX,
                    StatusBarArena.labelY,
                    iconFont,
                    Ui.Icons.ICON_CONNECTING,
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
                );

                dc.drawText(
                    startX + iconWidth + 5,
                    StatusBarArena.labelY,
                    textFont,
                    timeStr,
                    Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }

            dc.setColor(subColor, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(
                StatusBarArena.lineStartX,
                StatusBarArena.lineStartY,
                StatusBarArena.lineEndX,
                StatusBarArena.lineEndY
            );
        }

        function drawEventRow(
            dc as Graphics.Dc,
            y as Number,
            iconChar as String,
            timeStr as String,
            iconColor as Number,
            textColor as Number,
            subColor as Number,
            timeFont as Graphics.FontType,
            iconFont as Graphics.FontType
        ) as Void {
            var timeFontHeight = dc.getFontHeight(timeFont);
            var timeYOffset = (timeFontHeight * 0.07).toNumber();

            dc.setColor(iconColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                EventRowArena.iconX,
                y,
                iconFont,
                iconChar,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                EventRowArena.timeX,
                y - timeYOffset,
                timeFont,
                timeStr,
                EventRowArena.timeJustify
            );
        }

        function drawWatermark(
            dc as Graphics.Dc,
            waterMarkTitle as String,
            subColor as Number,
            font as Graphics.FontType
        ) as Void {
            dc.setColor(subColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                WatermarkArena.labelX,
                WatermarkArena.labelY,
                font,
                waterMarkTitle,
                WatermarkArena.justify
            );
        }
    }
}
