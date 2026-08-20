import Toybox.Lang;
import Toybox.Graphics;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.DetailsUiArena as detailA;

module Features {
    module Details {
        module Components {
            module DetailsRow {
                function render(
                    dc as Graphics.Dc,
                    centerY as Number,
                    label as String,
                    value as String,
                    accentColor as Graphics.ColorType,
                    iconText as String
                ) as Void {
                    var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();

                    var labelFont = MH.useFont(detailA.LABEL_FONT)
                        .init(Graphics.FONT_XTINY)
                        .req();
                    var valueFont = MH.useFont(detailA.VALUE_FONT)
                        .init(Graphics.FONT_XTINY)
                        .req();
                    var iconFont = MH.useFont(detailA.ICON_FONT)
                        .init(Graphics.FONT_XTINY)
                        .req();

                    var iconX = (w * 0.32).toNumber();
                    var textX = (w * 0.45).toNumber();

                    dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        iconX,
                        centerY,
                        iconFont,
                        iconText,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );

                    var lblHeight = dc.getFontHeight(labelFont);
                    var valHeight = dc.getFontHeight(valueFont);
                    var totalHeight = lblHeight + valHeight - 4;
                    var startY = centerY - totalHeight / 2;

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        textX,
                        startY,
                        labelFont,
                        label,
                        Graphics.TEXT_JUSTIFY_LEFT
                    );

                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        textX,
                        startY + lblHeight - 4,
                        valueFont,
                        value,
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                }
            }
        }
    }
}
