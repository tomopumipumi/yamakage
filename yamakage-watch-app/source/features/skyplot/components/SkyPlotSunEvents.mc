import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Core.ApiSchema;
import Shared.Icons;

module Features {
    module SkyPlot {
        module Components {
            module SkyPlotSunEvents {
                function render(
                    dc as Graphics.Dc,
                    sunPaths as ApiSchema.SunPathArray,
                    cx as Number,
                    cy as Number,
                    radius as Float,
                    iconFont as Graphics.FontType
                ) as Void {
                    var sunrisePoint = null;
                    var sunsetPoint = null;

                    if (sunPaths.size() > 1) {
                        for (var i = 0; i < sunPaths.size() - 1; i++) {
                            var sp1 =
                                sunPaths[i] as ApiSchema.SunPathPointTuple;
                            var sp2 =
                                sunPaths[i + 1] as ApiSchema.SunPathPointTuple;

                            var el1 =
                                sp1[ApiSchema.SunPathIndex.ALTITUDE].toFloat();
                            var el2 =
                                sp2[ApiSchema.SunPathIndex.ALTITUDE].toFloat();

                            if (el1 < 0.0 && el2 >= 0.0) {
                                sunrisePoint = sp2;
                            }

                            if (el1 >= 0.0 && el2 < 0.0) {
                                sunsetPoint = sp1;
                            }
                        }
                    }

                    dc.setColor(
                        Graphics.COLOR_ORANGE,
                        Graphics.COLOR_TRANSPARENT
                    );

                    if (sunrisePoint != null) {
                        var azDeg =
                            sunrisePoint[
                                ApiSchema.SunPathIndex.AZIMUTH
                            ].toFloat();
                        var rad = ((azDeg - 90.0) * Math.PI) / 180.0;
                        var px = cx + (radius * Math.cos(rad)).toNumber();
                        var py = cy + (radius * Math.sin(rad)).toNumber();

                        dc.setColor(
                            Graphics.COLOR_YELLOW,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            px,
                            py,
                            iconFont,
                            Icons.ICON_SUNRISE,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }

                    if (sunsetPoint != null) {
                        var azDeg =
                            sunsetPoint[
                                ApiSchema.SunPathIndex.AZIMUTH
                            ].toFloat();
                        var rad = ((azDeg - 90.0) * Math.PI) / 180.0;
                        var px = cx + (radius * Math.cos(rad)).toNumber();
                        var py = cy + (radius * Math.sin(rad)).toNumber();

                        dc.setColor(
                            Graphics.COLOR_PURPLE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            px,
                            py,
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
