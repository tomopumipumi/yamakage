import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Core.ApiSchema;
import Features.Panorama.PanoramaLogic;
import Shared.Ui.SunIcon;
import Shared.Ui.SonarPulse;
import Hal.DateTime;

module Features {
    module Panorama {
        module Components {
            module PanoramaSunPath {
                function render(
                    dc as Graphics.Dc,
                    paths as ApiSchema.PathArray,
                    heading as Float,
                    width as Number,
                    height as Number,
                    pulsePhase as Float
                ) as Void {
                    var points = PanoramaLogic.getPathPoints(
                        paths,
                        heading,
                        width,
                        height
                    );

                    dc.setColor(
                        Graphics.COLOR_YELLOW,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(2);

                    if (points.size() > 1) {
                        for (var i = 0; i < points.size() - 1; i++) {
                            if (
                                (points[i][0] - points[i + 1][0]).abs() <
                                width / 2
                            ) {
                                dc.drawLine(
                                    points[i][0],
                                    points[i][1],
                                    points[i + 1][0],
                                    points[i + 1][1]
                                );
                            }
                        }
                    }
                    dc.setPenWidth(1);

                    var now = DateTime.createTargetUnixTime();
                    var minTimeDiff = 99999999;
                    var currentPx = null;
                    var currentPy = null;

                    for (var i = 0; i < paths.size(); i++) {
                        var sp = paths[i] as ApiSchema.PathPointTuple;
                        var tVal = sp[Core.ApiSchema.PathIndex.TIME];
                        var t =
                            tVal instanceof Long
                                ? tVal.toNumber()
                                : tVal as Number;
                        var diff = (now - t).abs();

                        if (diff < minTimeDiff) {
                            minTimeDiff = diff;
                            var el =
                                sp[Core.ApiSchema.PathIndex.ALTITUDE].toFloat();
                            if (el >= 0.0) {
                                var az =
                                    sp[
                                        Core.ApiSchema.PathIndex.AZIMUTH
                                    ].toFloat();
                                currentPx = PanoramaLogic.getLabelXPos(
                                    az,
                                    heading,
                                    width
                                );
                                if (currentPx != null) {
                                    currentPy = PanoramaLogic.getYFromElevation(
                                        el,
                                        height
                                    );
                                }
                            } else {
                                currentPx = null;
                            }
                        }
                    }

                    if (currentPx != null && currentPy != null) {
                        SonarPulse.render(
                            dc,
                            currentPx,
                            currentPy,
                            pulsePhase,
                            Graphics.COLOR_YELLOW
                        );
                        SunIcon.render(dc, currentPx, currentPy);
                    }
                }
            }
        }
    }
}
