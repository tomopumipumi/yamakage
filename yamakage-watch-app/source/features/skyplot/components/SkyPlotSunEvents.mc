import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;
import Shared.Icons;
import Features.SkyPlot.SkyPlotLogic;

module Features {
    module SkyPlot {
        module Components {
            module SkyPlotSunEvents {
                function render(
                    dc as Graphics.Dc,
                    paths as ApiSchema.PathArray,
                    cx as Number,
                    cy as Number,
                    radius as Float,
                    iconFont as Graphics.FontType
                ) as Void {
                    var sunrisePoint = null;
                    var sunsetPoint = null;

                    if (paths.size() > 1) {
                        for (var i = 0; i < paths.size() - 1; i++) {
                            var sp1 = paths[i] as ApiSchema.PathPointTuple;
                            var sp2 = paths[i + 1] as ApiSchema.PathPointTuple;
                            var el1 =
                                sp1[ApiSchema.PathIndex.ALTITUDE].toFloat();
                            var el2 =
                                sp2[ApiSchema.PathIndex.ALTITUDE].toFloat();

                            if (el1 < 0.0 && el2 >= 0.0) {
                                sunrisePoint = sp2;
                            }
                            if (el1 >= 0.0 && el2 < 0.0) {
                                sunsetPoint = sp1;
                            }
                        }
                    }

                    if (sunrisePoint != null) {
                        var azDeg =
                            sunrisePoint[ApiSchema.PathIndex.AZIMUTH].toFloat();
                        var pos = SkyPlotLogic.getPolarCoordinates(
                            azDeg,
                            0.0,
                            cx,
                            cy,
                            radius
                        );

                        dc.setColor(
                            Graphics.COLOR_YELLOW,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            pos[0],
                            pos[1],
                            iconFont,
                            Icons.ICON_SUNRISE,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }

                    if (sunsetPoint != null) {
                        var azDeg =
                            sunsetPoint[ApiSchema.PathIndex.AZIMUTH].toFloat();
                        var pos = SkyPlotLogic.getPolarCoordinates(
                            azDeg,
                            0.0,
                            cx,
                            cy,
                            radius
                        );

                        dc.setColor(
                            Graphics.COLOR_PURPLE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            pos[0],
                            pos[1],
                            iconFont,
                            Icons.ICON_SUNSET,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }
                }
            }
        }
    }
}
