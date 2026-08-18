import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Features {
    module Error {
        module Components {
            module ErrorIcon {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    cy as Number,
                    pulse as Float
                ) as Void {
                    var baseRadius = 20;
                    var pulseRadius = baseRadius + Math.sin(pulse) * 4;

                    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
                    dc.fillCircle(cx, cy, pulseRadius.toNumber());

                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(cx, cy, 15);

                    dc.setColor(
                        Graphics.COLOR_DK_RED,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillRectangle(cx - 2, cy - 8, 4, 10);
                    dc.fillCircle(cx, cy + 6, 2.5);
                }
            }
        }
    }
}
