import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Shared.Ui.Button;

module Features {
    module Main {
        module Components {
            module MainStartAction {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    y as Number,
                    btnWidth as Number,
                    btnHeight as Number,
                    btnFont as Graphics.FontType,
                    isGpsReady as Boolean
                ) as Void {
                    var isTouch = System.getDeviceSettings().isTouchScreen;

                    var btnText = isGpsReady ? "START" : "WAIT GPS";
                    var btnColor = isGpsReady
                        ? Graphics.COLOR_DK_BLUE
                        : Graphics.COLOR_DK_GRAY;
                    var textColor = isGpsReady
                        ? Graphics.COLOR_WHITE
                        : Graphics.COLOR_LT_GRAY;

                    if (isTouch) {
                        Button.render(
                            dc,
                            btnText,
                            cx,
                            y,
                            btnWidth,
                            btnHeight,
                            btnFont,
                            btnColor,
                            textColor
                        );
                    } else {
                        var hintText = isGpsReady
                            ? "Press START"
                            : "Wait for GPS";
                        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
                        dc.drawText(
                            cx,
                            y,
                            Graphics.FONT_SMALL,
                            hintText,
                            Graphics.TEXT_JUSTIFY_CENTER |
                                Graphics.TEXT_JUSTIFY_VCENTER
                        );
                    }
                }
            }
        }
    }
}
