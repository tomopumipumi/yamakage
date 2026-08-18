import Toybox.Lang;
import Toybox.Graphics;

module Features {
    module SkyPlot {
        module Components {
            module SkyPlotGrid {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    cy as Number,
                    radius as Float,
                    font as Graphics.FontType
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );

                    var rNum = radius.toNumber();

                    dc.drawCircle(cx, cy, rNum);
                    dc.drawCircle(cx, cy, (radius / 2).toNumber());

                    dc.drawLine(cx, cy - rNum, cx, cy + rNum);
                    dc.drawLine(cx - rNum, cy, cx + rNum, cy);

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );

                    var margin = (dc.getFontHeight(font) * 0.6).toNumber();

                    dc.drawText(
                        cx,
                        cy - rNum - margin,
                        font,
                        "N",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );

                    dc.drawText(
                        cx + rNum + margin,
                        cy,
                        font,
                        "E",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );

                    dc.drawText(
                        cx,
                        cy + rNum + margin,
                        font,
                        "S",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );

                    dc.drawText(
                        cx - rNum - margin,
                        cy,
                        font,
                        "W",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
