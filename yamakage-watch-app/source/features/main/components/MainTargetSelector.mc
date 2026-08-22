import Toybox.Lang;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;
import Shared.Ui.SunIcon;
import Shared.Ui.MoonIcon;

module Features {
    module Main {
        module Components {
            module MainTargetSelector {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    y as Number,
                    mode as Number
                ) as Void {
                    var arrowW = 6;
                    var arrowH = 5;
                    var padding = 16;

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );

                    dc.fillPolygon([
                        [cx, y - padding - arrowH],
                        [cx - arrowW, y - padding],
                        [cx + arrowW, y - padding]
                    ]);

                    dc.fillPolygon([
                        [cx, y + padding + arrowH],
                        [cx - arrowW, y + padding],
                        [cx + arrowW, y + padding]
                    ]);

                    if (mode == TargetMode.SUN) {
                        SunIcon.render(dc, cx, y);
                    } else {
                        MoonIcon.render(dc, cx, y, 0.25, 0.25, 6);
                    }
                }
            }
        }
    }
}
