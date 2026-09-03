import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;
import Features.Radar.RadarLogic;

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

                    for (var i = 0; i < size; i++) {
                        var item1 = profiles[i];
                        var item2 = profiles[(i + 1) % size];

                        if (
                            !(item1 instanceof Array) ||
                            !(item2 instanceof Array) ||
                            item1.size() < 2 ||
                            item2.size() < 2
                        ) {
                            continue;
                        }

                        var azDeg1 = (i * stepDeg).toFloat();
                        var d1 =
                            item1[1] instanceof Number ||
                            item1[1] instanceof Float
                                ? item1[1].toFloat()
                                : 0.0;

                        var azDeg2 = azDeg1 + stepDeg;
                        var d2 =
                            item2[1] instanceof Number ||
                            item2[1] instanceof Float
                                ? item2[1].toFloat()
                                : 0.0;

                        var p1 = RadarLogic.getPolarCoordinates(
                            azDeg1,
                            d1,
                            cx,
                            cy,
                            radius
                        );
                        var p2 = RadarLogic.getPolarCoordinates(
                            azDeg2,
                            d2,
                            cx,
                            cy,
                            radius
                        );

                        dc.setColor(
                            Graphics.COLOR_DK_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillPolygon([
                            [cx, cy],
                            [p1[0], p1[1]],
                            [p2[0], p2[1]]
                        ]);

                        dc.setColor(
                            Graphics.COLOR_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.setPenWidth(2);
                        dc.drawLine(p1[0], p1[1], p2[0], p2[1]);
                    }
                    dc.setPenWidth(1);
                }
            }
        }
    }
}
