import Toybox.Lang;
import Toybox.Graphics;

module Shared {
    module Ui {
        module TextLabel {
            function render(
                dc as Graphics.Dc,
                text as String,
                x as Number,
                y as Number,
                font as Graphics.FontType
            ) as Void {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    x,
                    y,
                    font,
                    text,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
        }
    }
}
