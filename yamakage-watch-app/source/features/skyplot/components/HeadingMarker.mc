import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;
import Core.ApiSchema;

module Features {
    module SkyPlot {
        module Components {
            module HeadingMarker {
                function render(
                    dc as Graphics.Dc,
                    headingDeg as Float,
                    profiles as ApiSchema.AzimuthProfilesArray,
                    stepDeg as Number,
                    cx as Number,
                    cy as Number,
                    radius as Float
                ) as Void {
                    var rad = ((headingDeg - 90.0) * Math.PI) / 180.0;
                    var px = cx + (radius * Math.cos(rad)).toNumber();
                    var py = cy + (radius * Math.sin(rad)).toNumber();

                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(cx, cy, px, py);

                    var index = (headingDeg / stepDeg).toNumber();
                    if (index >= 0 && index < profiles.size()) {
                        var item = profiles[index];
                        if (item instanceof Array && item.size() > 0) {
                            var elF =
                                item[0] instanceof Number ||
                                item[0] instanceof Float
                                    ? item[0].toFloat()
                                    : 0.0;
                            var r = radius * (1.0 - elF / 90.0);
                            if (r < 0) {
                                r = 0.0;
                            }

                            var mx = cx + (r * Math.cos(rad)).toNumber();
                            var my = cy + (r * Math.sin(rad)).toNumber();

                            dc.setColor(
                                Graphics.COLOR_BLUE,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.fillCircle(mx, my, 4);
                        }
                    }
                }
            }
        }
    }
}
