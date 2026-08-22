import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Shared.Ui.MoonIcon;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.DetailsUiArena as detailA;

module Features {
    module Details {
        module Components {
            module DetailsMoonRow {
                function render(
                    dc as Graphics.Dc,
                    centerY as Number,
                    label as String,
                    value as String,
                    accentColor as Graphics.ColorType,
                    fraction as Float,
                    phase as Float
                ) as Void {
                    var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();

                    var labelFont = MH.useFont(detailA.LABEL_FONT).req();
                    var valueFont = MH.useFont(detailA.VALUE_FONT).req();

                    var iconX = (w * 0.32).toNumber();
                    var textX = (w * 0.45).toNumber();

                    var radius = (w * 0.04).toNumber();

                    MoonIcon.render(
                        dc,
                        iconX,
                        centerY,
                        fraction,
                        phase,
                        radius
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
