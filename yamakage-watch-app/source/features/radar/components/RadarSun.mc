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
                    paths as ApiSchema.PathArray,
                    cx as Number,
                    cy as Number,
                    radius as Float
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
                            var pos = RadarLogic.getIconCoordinates(
                                az,
                                cx,
                                cy,
                                radius,
                                15
                            );
                            var px = pos[0];
                            var py = pos[1];

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
