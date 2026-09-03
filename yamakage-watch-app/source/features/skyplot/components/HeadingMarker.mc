import Toybox.Graphics;
import Toybox.Lang;
import Core.ApiSchema;
import Features.SkyPlot.SkyPlotLogic;

module Features {
    module SkyPlot {
        module Components {
            module HeadingMarker {
                function render(
                    dc as Graphics.Dc,
                    headingDeg as Float,
                    profiles as ApiSchema.AzimuthProfilesArray,
                    stepDeg as Number,
                    cx as Number,
                    cy as Number,
                    radius as Float
                ) as Void {
                    var edge = SkyPlotLogic.getPolarCoordinates(
                        headingDeg,
                        0.0,
                        cx,
                        cy,
                        radius
                    );

                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(cx, cy, edge[0], edge[1]);

                    var index = (headingDeg / stepDeg).toNumber();
                    if (index >= 0 && index < profiles.size()) {
                        var item = profiles[index];
                        if (item instanceof Array && item.size() > 0) {
                            var elF =
                                item[0] instanceof Number ||
                                item[0] instanceof Float
                                    ? item[0].toFloat()
                                    : 0.0;
                            var marker = SkyPlotLogic.getPolarCoordinates(
                                headingDeg,
                                elF,
                                cx,
                                cy,
                                radius
                            );

                            dc.setColor(
                                Graphics.COLOR_BLUE,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.fillCircle(marker[0], marker[1], 4);
                        }
                    }
                }
            }
        }
    }
}
