import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Features {
    module Main {
        module Components {
            module MainSettingsButton {
                function render(
                    dc as Graphics.Dc,
                    w as Number,
                    h as Number,
                    btnWidth as Number,
                    btnHeight as Number,
                    font as Graphics.FontType
                ) as Void {
                    var isTouch = System.getDeviceSettings().isTouchScreen;
                    if (!isTouch) {
                        return;
                    }

                    var x = (w * 0.15).toNumber();
                    var y = (h * 0.45).toNumber();

                    var startX = x - btnWidth / 2;
                    var startY = y - btnHeight / 2;

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );

                    dc.drawRoundedRectangle(
                        startX,
                        startY,
                        btnWidth,
                        btnHeight,
                        4
                    );

                    dc.drawText(
                        x,
                        y,
                        font,
                        "SET",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
