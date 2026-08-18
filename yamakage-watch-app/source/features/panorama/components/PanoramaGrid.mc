import Toybox.Graphics;
import Toybox.Lang;
import Features.Panorama.PanoramaLogic;

module Features {
    module Panorama {
        module Components {
            module PanoramaGrid {
                function render(
                    dc as Graphics.Dc,
                    width as Number,
                    height as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(1);

                    var elevations = [0.0, 30.0, 60.0];
                    for (var i = 0; i < elevations.size(); i++) {
                        var el = elevations[i] as Float;
                        var py = PanoramaLogic.getYFromElevation(el, height);

                        dc.drawLine(0, py, width, py);
                        dc.drawText(
                            width - 15,
                            py - 10,
                            Graphics.FONT_XTINY,
                            el.format("%d") + "°",
                            Graphics.TEXT_JUSTIFY_RIGHT
                        );
                    }
                }
            }
        }
    }
}
