import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Shared {
    module Ui {
        module SunIcon {
            function render(
                dc as Graphics.Dc,
                x as Number,
                y as Number
            ) as Void {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 5);

                dc.setPenWidth(1);
                for (var j = 0; j < 8; j++) {
                    var angle = (j * Math.PI) / 4.0;
                    var r1 = 7.0;
                    var r2 = 12.0;
                    dc.drawLine(
                        x + (Math.cos(angle) * r1).toNumber(),
                        y + (Math.sin(angle) * r1).toNumber(),
                        x + (Math.cos(angle) * r2).toNumber(),
                        y + (Math.sin(angle) * r2).toNumber()
                    );
                }
            }
        }
    }
}
