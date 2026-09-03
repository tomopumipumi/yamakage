import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;
import Features.SkyPlot.SkyPlotLogic;

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
                        var item1 = profiles[i];
                        var item2 = profiles[(i + 1) % size];

                        if (
                            !(item1 instanceof Array) ||
                            item1.size() == 0 ||
                            !(item2 instanceof Array) ||
                            item2.size() == 0
                        ) {
                            continue;
                        }

                        var azDeg1 = (i * stepDeg).toFloat();
                        var elDeg1 =
                            item1[0] instanceof Number ||
                            item1[0] instanceof Float
                                ? item1[0].toFloat()
                                : 0.0;
                        var azDeg2 = azDeg1 + stepDeg;
                        var elDeg2 =
                            item2[0] instanceof Number ||
                            item2[0] instanceof Float
                                ? item2[0].toFloat()
                                : 0.0;

                        var p1 = SkyPlotLogic.getPolarCoordinates(
                            azDeg1,
                            elDeg1,
                            cx,
                            cy,
                            radius
                        );
                        var p2 = SkyPlotLogic.getPolarCoordinates(
                            azDeg2,
                            elDeg2,
                            cx,
                            cy,
                            radius
                        );
                        var b1 = SkyPlotLogic.getPolarCoordinates(
                            azDeg1,
                            0.0,
                            cx,
                            cy,
                            radius
                        );
                        var b2 = SkyPlotLogic.getPolarCoordinates(
                            azDeg2,
                            0.0,
                            cx,
                            cy,
                            radius
                        );

                        dc.setColor(
                            Graphics.COLOR_DK_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillPolygon([
                            [p1[0], p1[1]],
                            [p2[0], p2[1]],
                            [b2[0], b2[1]],
                            [b1[0], b1[1]]
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
