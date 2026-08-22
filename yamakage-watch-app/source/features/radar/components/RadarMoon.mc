import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;
import Core.ApiSchema;
import Hal.DateTime;
import Shared.Ui.MoonIcon;

module Features {
    module Radar {
        module Components {
            module RadarMoon {
                function render(
                    dc as Graphics.Dc,
                    paths as ApiSchema.PathArray,
                    cx as Number,
                    cy as Number,
                    radius as Float,
                    fraction as Float,
                    phase as Float
                ) as Void {
                    if (paths.size() == 0) {
                        return;
                    }

                    var now = DateTime.createTargetUnixTime();
                    var minTimeDiff = 99999999;
                    var currentSp = null;

                    for (var i = 0; i < paths.size(); i++) {
                        var sp = paths[i] as ApiSchema.PathPointTuple;
                        var tVal = sp[ApiSchema.PathIndex.TIME];
                        var t =
                            tVal instanceof Long
                                ? tVal.toNumber()
                                : tVal as Number;
                        var diff = (now - t).abs();
                        if (diff < minTimeDiff) {
                            minTimeDiff = diff;
                            currentSp = sp;
                        }
                    }

                    if (currentSp != null) {
                        var el =
                            currentSp[ApiSchema.PathIndex.ALTITUDE].toFloat();
                        if (el >= 0.0) {
                            var az =
                                currentSp[
                                    ApiSchema.PathIndex.AZIMUTH
                                ].toFloat();
                            var rad = ((az - 90.0) * Math.PI) / 180.0;
                            var r = radius + 15;
                            var px = cx + (r * Math.cos(rad)).toNumber();
                            var py = cy + (r * Math.sin(rad)).toNumber();

                            MoonIcon.render(dc, px, py, fraction, phase, 6);

                            dc.setColor(
                                Graphics.COLOR_LT_GRAY,
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
