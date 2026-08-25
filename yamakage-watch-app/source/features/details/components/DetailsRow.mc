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
                    iconText as String,
                    layoutCtx as Array
                ) as Void {
                    var w = layoutCtx[0] as Number;
                    var labelFont = layoutCtx[1] as Graphics.FontType;
                    var valueFont = layoutCtx[2] as Graphics.FontType;
                    var iconFont = layoutCtx[3] as Graphics.FontType;

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
