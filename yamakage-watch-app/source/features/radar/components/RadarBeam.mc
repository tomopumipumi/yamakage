import Toybox.Graphics;
import Toybox.Lang;
import Core.ApiSchema;
import Features.Radar.RadarLogic;

module Features {
    module Radar {
        module Components {
            module RadarBeam {
                function render(
                    dc as Graphics.Dc,
                    headingDeg as Float,
                    profiles as ApiSchema.AzimuthProfilesArray,
                    stepDeg as Number,
                    cx as Number,
                    cy as Number,
                    radius as Float
                ) as Void {
                    var edge = RadarLogic.getPolarCoordinates(
                        headingDeg,
                        RadarLogic.MAX_DISTANCE_M,
                        cx,
                        cy,
                        radius
                    );

                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                    dc.setPenWidth(2);
                    dc.drawLine(cx, cy, edge[0], edge[1]);

                    dc.setPenWidth(1);
                    dc.setColor(
                        Graphics.COLOR_DK_RED,
                        Graphics.COLOR_TRANSPARENT
                    );

                    for (var i = -15; i <= 15; i += 5) {
                        if (i == 0) {
                            continue;
                        }
                        var bPos = RadarLogic.getPolarCoordinates(
                            headingDeg + i,
                            RadarLogic.MAX_DISTANCE_M,
                            cx,
                            cy,
                            radius
                        );
                        dc.drawLine(cx, cy, bPos[0], bPos[1]);
                    }

                    var index = (headingDeg / stepDeg).toNumber();
                    var distStr = "";

                    if (index >= 0 && index < profiles.size()) {
                        var item = profiles[index];
                        if (item instanceof Array && item.size() >= 2) {
                            var d =
                                item[1] instanceof Number ||
                                item[1] instanceof Float
                                    ? item[1].toFloat()
                                    : 0.0;
                            distStr = RadarLogic.formatDistance(d);
                        }
                    }

                    if (!distStr.equals("")) {
                        var lblPos = RadarLogic.getPolarCoordinates(
                            headingDeg,
                            RadarLogic.MAX_DISTANCE_M * 0.7,
                            cx,
                            cy,
                            radius
                        );
                        var lx = lblPos[0];
                        var ly = lblPos[1];

                        var font = Graphics.FONT_XTINY;
                        var textDims = dc.getTextDimensions(distStr, font);
                        var tw = textDims[0];
                        var th = textDims[1];

                        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                        dc.fillRoundedRectangle(
                            lx - tw / 2 - 2,
                            ly - th / 2 - 1,
                            tw + 4,
                            th + 2,
                            2
                        );

                        dc.setColor(
                            Graphics.COLOR_WHITE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.drawText(
                            lx,
                            ly,
                            font,
                            distStr,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }
                }
            }
        }
    }
}
