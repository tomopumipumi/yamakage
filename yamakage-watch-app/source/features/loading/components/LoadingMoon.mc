import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Features {
    module Loading {
        module Components {
            module LoadingMoon {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    cy as Number,
                    angle as Float
                ) as Void {
                    var px = cx + (Math.cos(angle) * 20).toNumber();
                    var py = cy + (Math.sin(angle) * 20).toNumber();

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(px, py, 10);

                    dc.setColor(
                        Graphics.COLOR_BLACK,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(px + 4, py - 4, 8);
                }
            }
        }
    }
}
