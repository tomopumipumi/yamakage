import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Shared {
    module Ui {
        module MoonIcon {
            function render(
                dc as Graphics.Dc,
                x as Number,
                y as Number,
                fraction as Float,
                phase as Float
            ) as Void {
                var radius = 6;

                var isNewMoon = fraction < 0.05;
                var isFullMoon = fraction > 0.95;

                if (isNewMoon) {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawCircle(x, y, radius);
                    return;
                }

                if (isFullMoon) {
                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(x, y, radius);
                    return;
                }

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, radius);

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

                var offset = ((1.0 - fraction) * radius * 2.0).toNumber();
                var isWaxing = phase > 0.0 && phase < 0.5;

                if (isWaxing) {
                    dc.fillCircle(x - offset, y, radius);
                } else {
                    dc.fillCircle(x + offset, y, radius);
                }
            }
        }
    }
}
