import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Core.ApiSchema;

module Features {
    module Radar {
        module Components {
            module RadarArea {
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

                    var maxDist = 30000.0;

                    for (var i = 0; i < size; i++) {
                        var item1 = profiles[i];
                        var nextIndex = (i + 1) % size;
                        var item2 = profiles[nextIndex];

                        if (
                            !(item1 instanceof Array) ||
                            !(item2 instanceof Array) ||
                            item1.size() < 2 ||
                            item2.size() < 2
                        ) {
                            continue;
                        }

                        var azDeg1 = i * stepDeg;
                        var d1 =
                            item1[1] instanceof Number ||
                            item1[1] instanceof Float
                                ? item1[1].toFloat()
                                : maxDist;
                        if (d1 <= 0.0 || d1 > 100000.0) {
                            d1 = maxDist;
                        }

                        var azDeg2 = azDeg1 + stepDeg;
                        var d2 =
                            item2[1] instanceof Number ||
                            item2[1] instanceof Float
                                ? item2[1].toFloat()
                                : maxDist;
                        if (d2 <= 0.0 || d2 > 100000.0) {
                            d2 = maxDist;
                        }

                        var r1 = radius * (d1 / maxDist);
                        var r2 = radius * (d2 / maxDist);

                        if (r1 > radius) {
                            r1 = radius;
                        }
                        if (r2 > radius) {
                            r2 = radius;
                        }

                        var rad1 = ((azDeg1 - 90.0) * Math.PI) / 180.0;
                        var rad2 = ((azDeg2 - 90.0) * Math.PI) / 180.0;

                        var p1x = cx + (r1 * Math.cos(rad1)).toNumber();
                        var p1y = cy + (r1 * Math.sin(rad1)).toNumber();
                        var p2x = cx + (r2 * Math.cos(rad2)).toNumber();
                        var p2y = cy + (r2 * Math.sin(rad2)).toNumber();

                        dc.setColor(
                            Graphics.COLOR_DK_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillPolygon([
                            [cx, cy],
                            [p1x, p1y],
                            [p2x, p2y]
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
