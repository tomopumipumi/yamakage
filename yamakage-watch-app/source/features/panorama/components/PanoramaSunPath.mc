import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Core.ApiSchema;
import Features.Panorama.PanoramaLogic;
import Shared.Ui.SunIcon;

module Features {
    module Panorama {
        module Components {
            module PanoramaSunPath {
                function render(
                    dc as Graphics.Dc,
                    sunPaths as ApiSchema.SunPathArray,
                    heading as Float,
                    width as Number,
                    height as Number
                ) as Void {
                    var sunPoints = PanoramaLogic.getSunPathPoints(
                        sunPaths,
                        heading,
                        width,
                        height
                    );

                    dc.setColor(
                        Graphics.COLOR_YELLOW,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(2);

                    if (sunPoints.size() > 1) {
                        for (var i = 0; i < sunPoints.size() - 1; i++) {
                            if (
                                (sunPoints[i][0] - sunPoints[i + 1][0]).abs() <
                                width / 2
                            ) {
                                dc.drawLine(
                                    sunPoints[i][0],
                                    sunPoints[i][1],
                                    sunPoints[i + 1][0],
                                    sunPoints[i + 1][1]
                                );
                            }
                        }
                    }
                    dc.setPenWidth(1);

                    if (sunPaths.size() == 0) {
                        return;
                    }

                    var now = Time.now().value();
                    var minTimeDiff = 99999999;
                    var currentSunSp = null;

                    for (var i = 0; i < sunPaths.size(); i++) {
                        var sp = sunPaths[i] as ApiSchema.SunPathPointTuple;
                        var tVal = sp[Core.ApiSchema.SunPathIndex.TIME];
                        var t =
                            tVal instanceof Long
                                ? tVal.toNumber()
                                : tVal as Number;

                        var diff = now - t;
                        if (diff < 0) {
                            diff = -diff;
                        }

                        if (diff < minTimeDiff) {
                            minTimeDiff = diff;
                            currentSunSp = sp;
                        }
                    }

                    if (currentSunSp != null) {
                        var el =
                            currentSunSp[
                                Core.ApiSchema.SunPathIndex.ALTITUDE
                            ].toFloat();
                        if (el >= 0) {
                            var az =
                                currentSunSp[
                                    Core.ApiSchema.SunPathIndex.AZIMUTH
                                ].toFloat();
                            var px = PanoramaLogic.getLabelXPos(
                                az,
                                heading,
                                width
                            );

                            if (px != null) {
                                var py = PanoramaLogic.getYFromElevation(
                                    el,
                                    height
                                );
                                SunIcon.render(dc, px, py);
                            }
                        }
                    }
                }
            }
        }
    }
}
