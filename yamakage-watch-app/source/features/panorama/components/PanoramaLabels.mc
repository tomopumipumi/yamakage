import Toybox.Graphics;
import Toybox.Lang;
import Features.Panorama.PanoramaLogic;

module Features {
    module Panorama {
        module Components {
            module PanoramaLabels {
                function render(
                    dc as Graphics.Dc,
                    heading as Float,
                    width as Number,
                    height as Number,
                    cx as Number
                ) as Void {
                    var headings =
                        [
                            [0.0, "N"],
                            [90.0, "E"],
                            [180.0, "S"],
                            [270.0, "W"]
                        ] as Array<Array<Object> >;

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    var font = Graphics.FONT_SMALL;

                    for (var i = 0; i < headings.size(); i++) {
                        var az = headings[i][0] as Float;
                        var label = headings[i][1] as String;

                        var lx = PanoramaLogic.getLabelXPos(az, heading, width);
                        if (lx != null) {
                            dc.drawText(
                                lx,
                                (height * 0.15).toNumber(),
                                font,
                                label,
                                Graphics.TEXT_JUSTIFY_CENTER
                            );
                        }
                    }

                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                    dc.setPenWidth(2);
                    dc.drawLine(cx, height * 0.8, cx, height * 0.2);
                }
            }
        }
    }
}
