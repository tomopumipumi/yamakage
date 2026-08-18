import Toybox.Lang;
import Toybox.Graphics;

module Shared {
    module Ui {
        module PageIndicator {
            function render(
                dc as Graphics.Dc,
                numPages as Number,
                currentPage as Number,
                width as Number,
                height as Number
            ) as Void {
                var dotRadius = 3;
                var spacing = 16;

                var cx = (width * 0.08).toNumber();
                if (cx < 12) {
                    cx = 12;
                }

                var totalHeight = (numPages - 1) * spacing;
                var startY = height / 2 - totalHeight / 2;

                for (var i = 0; i < numPages; i++) {
                    var cy = startY + i * spacing;

                    if (i == currentPage) {
                        dc.setColor(
                            Graphics.COLOR_WHITE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillCircle(cx, cy, dotRadius);
                    } else {
                        dc.setColor(
                            Graphics.COLOR_DK_GRAY,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillCircle(cx, cy, dotRadius);
                    }
                }
            }
        }
    }
}
