import Toybox.Graphics;
import Toybox.Lang;
import Core.ApiSchema;
import Features.Panorama.PanoramaLogic;
import Shared.Icons;

module Features {
    module Panorama {
        module Components {
            module PanoramaSunEvents {
                function render(
                    dc as Graphics.Dc,
                    paths as ApiSchema.PathArray,
                    heading as Float,
                    width as Number,
                    height as Number,
                    iconFont as Graphics.FontType
                ) as Void {
                    var sunrisePoint = null;
                    var sunsetPoint = null;

                    for (var i = 0; i < paths.size(); i++) {
                        var sp = paths[i] as ApiSchema.PathPointTuple;
                        var el = sp[ApiSchema.PathIndex.ALTITUDE].toFloat();
                        if (el >= 0.0) {
                            if (sunrisePoint == null) {
                                sunrisePoint = sp;
                            }
                            sunsetPoint = sp;
                        }
                    }

                    var horizonY = PanoramaLogic.getYFromElevation(0.0, height);

                    if (sunrisePoint != null) {
                        var az =
                            sunrisePoint[ApiSchema.PathIndex.AZIMUTH].toFloat();
                        var px = PanoramaLogic.getLabelXPos(az, heading, width);
                        if (px != null) {
                            dc.setColor(
                                Graphics.COLOR_YELLOW,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.drawText(
                                px,
                                horizonY,
                                iconFont,
                                Icons.ICON_SUNRISE,
                                Graphics.TEXT_JUSTIFY_CENTER |
                                    Graphics.TEXT_JUSTIFY_VCENTER
                            );
                        }
                    }

                    if (sunsetPoint != null) {
                        var az =
                            sunsetPoint[ApiSchema.PathIndex.AZIMUTH].toFloat();
                        var px = PanoramaLogic.getLabelXPos(az, heading, width);
                        if (px != null) {
                            dc.setColor(
                                Graphics.COLOR_PURPLE,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.drawText(
                                px,
                                horizonY,
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
}
