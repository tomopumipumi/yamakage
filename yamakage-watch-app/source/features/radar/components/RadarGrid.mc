import Toybox.Lang;
import Toybox.Graphics;

module Features {
    module Radar {
        module Components {
            module RadarGrid {
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

                    dc.drawCircle(cx, cy, (radius * 0.33).toNumber());
                    dc.drawCircle(cx, cy, (radius * 0.66).toNumber());
                    dc.drawCircle(cx, cy, rNum);

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

                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        cx + (radius * 0.33).toNumber(),
                        cy + 2,
                        Graphics.FONT_XTINY,
                        "10",
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                    dc.drawText(
                        cx + (radius * 0.66).toNumber(),
                        cy + 2,
                        Graphics.FONT_XTINY,
                        "20",
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                    dc.drawText(
                        cx + rNum,
                        cy + 2,
                        Graphics.FONT_XTINY,
                        "30",
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                }
            }
        }
    }
}
