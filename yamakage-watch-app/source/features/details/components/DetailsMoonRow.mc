import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Shared.Ui.MoonIcon;

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
                    phase as Float,
                    layoutCtx as Array
                ) as Void {
                    var w = layoutCtx[0] as Number;
                    var labelFont = layoutCtx[1] as Graphics.FontType;
                    var valueFont = layoutCtx[2] as Graphics.FontType;

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
