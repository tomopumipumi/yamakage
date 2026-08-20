import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.Time;
import Core.ApiSchema;
import Core.ApiSchema.SunPathIndex;
import Shared.Ui.SunIcon;
import Hal.DateTime;

module Features {
    module SkyPlot {
        module Components {
            module SunPathChart {
                function render(
                    dc as Graphics.Dc,
                    sunPaths as ApiSchema.SunPathArray,
                    cx as Number,
                    cy as Number,
                    radius as Float
                ) as Void {
                    if (sunPaths.size() == 0) {
                        return;
                    }

                    dc.setColor(
                        Graphics.COLOR_YELLOW,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(2);

                    var lastX = -1;
                    var lastY = -1;

                    var now = DateTime.createTargetUnixTime();
                    var minTimeDiff = 99999999;
                    var currentSunPx = -1;
                    var currentSunPy = -1;

                    for (var i = 0; i < sunPaths.size(); i++) {
                        var sp = sunPaths[i] as ApiSchema.SunPathPointTuple;
                        var azDeg = sp[SunPathIndex.AZIMUTH].toFloat();
                        var elDeg = sp[SunPathIndex.ALTITUDE].toFloat();

                        var tVal = sp[SunPathIndex.TIME];
                        var t =
                            tVal instanceof Long
                                ? tVal.toNumber()
                                : tVal as Number;

                        if (elDeg < 0.0) {
                            lastX = -1;
                            lastY = -1;
                            continue;
                        }

                        var r = radius * (1.0 - elDeg / 90.0);
                        if (r < 0.0) {
                            r = 0.0;
                        }

                        var rad = ((azDeg - 90.0) * Math.PI) / 180.0;
                        var px = cx + (r * Math.cos(rad)).toNumber();
                        var py = cy + (r * Math.sin(rad)).toNumber();

                        if (lastX != -1 && lastY != -1) {
                            dc.drawLine(lastX, lastY, px, py);
                        }
                        lastX = px;
                        lastY = py;

                        var diff = now - t;
                        if (diff < 0) {
                            diff = -diff;
                        }

                        if (diff < minTimeDiff) {
                            minTimeDiff = diff;
                            currentSunPx = px;
                            currentSunPy = py;
                        }
                    }

                    dc.setPenWidth(1);

                    if (currentSunPx != -1 && currentSunPy != -1) {
                        SunIcon.render(dc, currentSunPx, currentSunPy);
                    }
                }
            }
        }
    }
}
