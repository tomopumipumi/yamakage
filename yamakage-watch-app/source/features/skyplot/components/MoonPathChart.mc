import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
import Core.ApiSchema;
import Shared.Ui.MoonIcon;
import Hal.DateTime;

module Features {
    module SkyPlot {
        module Components {
            module MoonPathChart {
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

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(2);

                    var lastX = -1;
                    var lastY = -1;

                    var now = DateTime.createTargetUnixTime();
                    var minTimeDiff = 99999999;
                    var currentPx = -1;
                    var currentPy = -1;

                    for (var i = 0; i < paths.size(); i++) {
                        var sp = paths[i] as ApiSchema.PathPointTuple;
                        var azDeg = sp[ApiSchema.PathIndex.AZIMUTH].toFloat();
                        var elDeg = sp[ApiSchema.PathIndex.ALTITUDE].toFloat();

                        var tVal = sp[ApiSchema.PathIndex.TIME];
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

                        var diff = (now - t).abs();
                        if (diff < minTimeDiff) {
                            minTimeDiff = diff;
                            currentPx = px;
                            currentPy = py;
                        }
                    }

                    dc.setPenWidth(1);

                    if (currentPx != -1 && currentPy != -1) {
                        MoonIcon.render(
                            dc,
                            currentPx,
                            currentPy,
                            fraction,
                            phase
                        );
                    }
                }
            }
        }
    }
}
