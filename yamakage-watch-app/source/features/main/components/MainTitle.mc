import Toybox.Lang;
import Toybox.Graphics;
import Shared.Core.Consts;

module Features {
    module Main {
        module Components {
            module MainTitle {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    y as Number,
                    font as Graphics.FontType
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        cx,
                        y,
                        font,
                        Consts.APP_TITLE,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
