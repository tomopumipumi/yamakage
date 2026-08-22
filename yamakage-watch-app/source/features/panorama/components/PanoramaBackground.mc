import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Features {
    module Panorama {
        module Components {
            module PanoramaBackground {
                function render(
                    dc as Graphics.Dc,
                    mode as Number,
                    buffer as Array<Number or Float>
                ) as Void {
                    if (mode == 0) {
                        dc.setColor(
                            Graphics.COLOR_DK_GRAY,
                            Graphics.COLOR_TRANSPARENT
                        );

                        var numClouds = buffer.size() / 4;
                        for (var i = 0; i < numClouds; i++) {
                            var idx = i * 4;
                            var x = buffer[idx].toNumber();
                            var y = buffer[idx + 1].toNumber();
                            var size = buffer[idx + 3].toNumber();

                            dc.fillCircle(x, y, size + 3);
                            dc.fillCircle(x - size - 4, y + 2, size + 1);
                            dc.fillCircle(x + size + 4, y + 2, size);
                        }
                    } else {
                        var numStars = buffer.size() / 3;
                        for (var i = 0; i < numStars; i++) {
                            var idx = i * 3;
                            var x = buffer[idx].toNumber();
                            var y = buffer[idx + 1].toNumber();
                            var phase = buffer[idx + 2].toFloat();

                            var brightness = Math.sin(phase);

                            if (brightness > 0.8) {
                                dc.setColor(
                                    Graphics.COLOR_WHITE,
                                    Graphics.COLOR_TRANSPARENT
                                );
                                dc.drawPoint(x, y);
                                dc.drawPoint(x + 1, y);
                                dc.drawPoint(x, y + 1);
                            } else if (brightness > 0.0) {
                                dc.setColor(
                                    Graphics.COLOR_LT_GRAY,
                                    Graphics.COLOR_TRANSPARENT
                                );
                                dc.drawPoint(x, y);
                            } else if (brightness > -0.5) {
                                dc.setColor(
                                    Graphics.COLOR_DK_GRAY,
                                    Graphics.COLOR_TRANSPARENT
                                );
                                dc.drawPoint(x, y);
                            }
                        }
                    }
                }
            }
        }
    }
}
