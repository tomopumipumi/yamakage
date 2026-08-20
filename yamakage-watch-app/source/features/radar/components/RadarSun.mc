import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;
import Core.ApiSchema;
import Hal.DateTime;
import Shared.Ui.SunIcon;

module Features {
    module Radar {
        module Components {
            module RadarSun {
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

                    var now = DateTime.createTargetUnixTime();
                    var minTimeDiff = 99999999;
                    var currentSunSp = null;

                    for (var i = 0; i < sunPaths.size(); i++) {
                        var sp = sunPaths[i] as ApiSchema.SunPathPointTuple;
                        var tVal = sp[ApiSchema.SunPathIndex.TIME];
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
                                ApiSchema.SunPathIndex.ALTITUDE
                            ].toFloat();
                        if (el >= 0.0) {
                            var az =
                                currentSunSp[
                                    ApiSchema.SunPathIndex.AZIMUTH
                                ].toFloat();
                            var rad = ((az - 90.0) * Math.PI) / 180.0;

                            var r = radius + 15;
                            var px = cx + (r * Math.cos(rad)).toNumber();
                            var py = cy + (r * Math.sin(rad)).toNumber();

                            SunIcon.render(dc, px, py);

                            dc.setColor(
                                Graphics.COLOR_YELLOW,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.setPenWidth(1);
                            dc.drawLine(cx, cy, px, py);
                        }
                    }
                }
            }
        }
    }
}
