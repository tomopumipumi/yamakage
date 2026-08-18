import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Core.ApiSchema;

module Features {
    module SkyPlot {
        module Components {
            module AzimuthChart {
                function render(
                    dc as Graphics.Dc,
                    profiles as ApiSchema.AzimuthProfilesArray,
                    stepDeg as Number,
                    cx as Number,
                    cy as Number,
                    radius as Float
                ) as Void {
                    var size = profiles.size();
                    if (size == 0) {
                        return;
                    }

                    for (var i = 0; i < size; i++) {
                        var nextIndex = (i + 1) % size;

                        var azDeg1 = i * stepDeg;
                        var elDeg1 = profiles[i].toFloat();

                        var azDeg2 = azDeg1 + stepDeg;
                        var elDeg2 = profiles[nextIndex].toFloat();

                        var r1 = radius * (1.0 - elDeg1 / 90.0);
                        if (r1 < 0) {
                            r1 = 0.0;
                        }
                        var r2 = radius * (1.0 - elDeg2 / 90.0);
                        if (r2 < 0) {
                            r2 = 0.0;
                        }

                        var rad1 = ((azDeg1 - 90.0) * Math.PI) / 180.0;
                        var rad2 = ((azDeg2 - 90.0) * Math.PI) / 180.0;

                        var p1x = cx + (r1 * Math.cos(rad1)).toNumber();
                        var p1y = cy + (r1 * Math.sin(rad1)).toNumber();
                        var p2x = cx + (r2 * Math.cos(rad2)).toNumber();
                        var p2y = cy + (r2 * Math.sin(rad2)).toNumber();

                        var b1x = cx + (radius * Math.cos(rad1)).toNumber();
                        var b1y = cy + (radius * Math.sin(rad1)).toNumber();
                        var b2x = cx + (radius * Math.cos(rad2)).toNumber();
                        var b2y = cy + (radius * Math.sin(rad2)).toNumber();

                        dc.setColor(
                            Graphics.COLOR_DK_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillPolygon([
                            [p1x, p1y],
                            [p2x, p2y],
                            [b2x, b2y],
                            [b1x, b1y]
                        ]);

                        dc.setColor(
                            Graphics.COLOR_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.setPenWidth(2);
                        dc.drawLine(p1x, p1y, p2x, p2y);
                    }

                    dc.setPenWidth(1);
                }
            }
        }
    }
}
