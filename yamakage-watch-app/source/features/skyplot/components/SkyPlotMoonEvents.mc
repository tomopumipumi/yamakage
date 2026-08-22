import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Core.ApiSchema;
import Shared.Icons;

module Features {
    module SkyPlot {
        module Components {
            module SkyPlotMoonEvents {
                function render(
                    dc as Graphics.Dc,
                    paths as ApiSchema.PathArray,
                    cx as Number,
                    cy as Number,
                    radius as Float,
                    iconFont as Graphics.FontType
                ) as Void {
                    var moonrisePoint = null;
                    var moonsetPoint = null;

                    if (paths.size() > 1) {
                        for (var i = 0; i < paths.size() - 1; i++) {
                            var sp1 = paths[i] as ApiSchema.PathPointTuple;
                            var sp2 = paths[i + 1] as ApiSchema.PathPointTuple;
                            var el1 =
                                sp1[ApiSchema.PathIndex.ALTITUDE].toFloat();
                            var el2 =
                                sp2[ApiSchema.PathIndex.ALTITUDE].toFloat();
                            if (el1 < 0.0 && el2 >= 0.0) {
                                moonrisePoint = sp2;
                            }
                            if (el1 >= 0.0 && el2 < 0.0) {
                                moonsetPoint = sp1;
                            }
                        }
                    }

                    if (moonrisePoint != null) {
                        var azDeg =
                            moonrisePoint[
                                ApiSchema.PathIndex.AZIMUTH
                            ].toFloat();
                        var rad = ((azDeg - 90.0) * Math.PI) / 180.0;
                        var px = cx + (radius * Math.cos(rad)).toNumber();
                        var py = cy + (radius * Math.sin(rad)).toNumber();
                        dc.setColor(
                            Graphics.COLOR_WHITE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            px,
                            py,
                            iconFont,
                            Icons.ICON_MOONRISE,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }

                    if (moonsetPoint != null) {
                        var azDeg =
                            moonsetPoint[ApiSchema.PathIndex.AZIMUTH].toFloat();
                        var rad = ((azDeg - 90.0) * Math.PI) / 180.0;
                        var px = cx + (radius * Math.cos(rad)).toNumber();
                        var py = cy + (radius * Math.sin(rad)).toNumber();
                        dc.setColor(
                            Graphics.COLOR_LT_GRAY,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            px,
                            py,
                            iconFont,
                            Icons.ICON_MOONSET,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }
                }
            }
        }
    }
}
