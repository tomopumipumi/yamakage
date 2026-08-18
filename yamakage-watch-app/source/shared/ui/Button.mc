import Toybox.Lang;
import Toybox.Graphics;

module Shared {
    module Ui {
        module Button {
            function render(
                dc as Graphics.Dc,
                text as String,
                x as Number,
                y as Number,
                width as Number,
                height as Number,
                font as Graphics.FontType,
                bgColor as Graphics.ColorType,
                textColor as Graphics.ColorType
            ) as Void {
                var cornerRadius = height / 4;
                var startX = x - width / 2;
                var startY = y - height / 2;

                dc.setColor(bgColor, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(
                    startX,
                    startY,
                    width,
                    height,
                    cornerRadius
                );

                dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
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
