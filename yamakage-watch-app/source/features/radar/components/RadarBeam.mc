import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;
import Core.ApiSchema;

module Features {
    module Radar {
        module Components {
            module RadarBeam {
                function render(
                    dc as Graphics.Dc,
                    headingDeg as Float,
                    profiles as ApiSchema.AzimuthProfilesArray,
                    stepDeg as Number,
                    cx as Number,
                    cy as Number,
                    radius as Float
                ) as Void {
                    var rad = ((headingDeg - 90.0) * Math.PI) / 180.0;
                    var px = cx + (radius * Math.cos(rad)).toNumber();
                    var py = cy + (radius * Math.sin(rad)).toNumber();

                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                    dc.setPenWidth(2);
                    dc.drawLine(cx, cy, px, py);

                    dc.setPenWidth(1);
                    dc.setColor(
                        Graphics.COLOR_DK_RED,
                        Graphics.COLOR_TRANSPARENT
                    );
                    for (var i = -15; i <= 15; i += 5) {
                        if (i == 0) {
                            continue;
                        }
                        var bRad = ((headingDeg + i - 90.0) * Math.PI) / 180.0;
                        var bx = cx + (radius * Math.cos(bRad)).toNumber();
                        var by = cy + (radius * Math.sin(bRad)).toNumber();
                        dc.drawLine(cx, cy, bx, by);
                    }

                    var index = (headingDeg / stepDeg).toNumber();
                    var distStr = "";

                    if (index >= 0 && index < profiles.size()) {
                        var item = profiles[index];
                        if (item instanceof Array && item.size() >= 2) {
                            var d =
                                item[1] instanceof Number ||
                                item[1] instanceof Float
                                    ? item[1].toFloat()
                                    : 30000.0;
                            if (d <= 0.0 || d >= 30000.0) {
                                distStr = ">30km";
                            } else {
                                distStr = (d / 1000.0).format("%.1f") + "km";
                            }
                        }
                    }

                    if (!distStr.equals("")) {
                        var lx = cx + (radius * 0.7 * Math.cos(rad)).toNumber();
                        var ly = cy + (radius * 0.7 * Math.sin(rad)).toNumber();

                        var font = Graphics.FONT_XTINY;
                        var textDims = dc.getTextDimensions(distStr, font);
                        var tw = textDims[0];
                        var th = textDims[1];

                        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                        dc.fillRoundedRectangle(
                            lx - tw / 2 - 2,
                            ly - th / 2 - 1,
                            tw + 4,
                            th + 2,
                            2
                        );

                        dc.setColor(
                            Graphics.COLOR_WHITE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            lx,
                            ly,
                            font,
                            distStr,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }
                }
            }
        }
    }
}
