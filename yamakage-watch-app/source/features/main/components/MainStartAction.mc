import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Shared.Core.Enums.TargetMode;

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
                    isGpsReady as Boolean,
                    mode as Number
                ) as Void {
                    var isTouch = System.getDeviceSettings().isTouchScreen;

                    var btnText = isGpsReady
                        ? isTouch
                            ? "START"
                            : "PRESS START"
                        : "NO GPS";

                    var displayFont =
                        isGpsReady && isTouch ? btnFont : Graphics.FONT_XTINY;

                    var borderColor;
                    var textColor;

                    if (isGpsReady) {
                        borderColor =
                            mode == TargetMode.SUN
                                ? Graphics.COLOR_ORANGE
                                : Graphics.COLOR_BLUE;
                        textColor = Graphics.COLOR_WHITE;
                    } else {
                        borderColor = Graphics.COLOR_DK_GRAY;
                        textColor = Graphics.COLOR_LT_GRAY;
                    }

                    var radius = btnHeight / 2;
                    var startX = cx - btnWidth / 2;
                    var startY = y - btnHeight / 2;

                    dc.setPenWidth(2);
                    dc.setColor(borderColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawRoundedRectangle(
                        startX,
                        startY,
                        btnWidth,
                        btnHeight,
                        radius
                    );
                    dc.setPenWidth(1);

                    dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        cx,
                        y,
                        displayFont,
                        btnText,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
