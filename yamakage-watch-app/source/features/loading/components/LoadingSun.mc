import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Features {
    module Loading {
        module Components {
            module LoadingSun {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    cy as Number,
                    angle as Float
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_ORANGE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(cx, cy, 15);
                    dc.setPenWidth(2);
                    for (var j = 0; j < 8; j++) {
                        var a = angle + (j * Math.PI) / 4.0;
                        var r1 = 20.0;
                        var r2 = 28.0 + Math.sin(angle * 4.0 + j) * 4.0;
                        dc.drawLine(
                            cx + (Math.cos(a) * r1).toNumber(),
                            cy + (Math.sin(a) * r1).toNumber(),
                            cx + (Math.cos(a) * r2).toNumber(),
                            cy + (Math.sin(a) * r2).toNumber()
                        );
                    }
                    dc.setPenWidth(1);
                }
            }
        }
    }
}
