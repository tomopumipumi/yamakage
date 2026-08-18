import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Features {
    module Error {
        module Components {
            module ErrorMessage {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    msgY as Number,
                    hintY as Number,
                    errMsg as String
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        cx,
                        msgY,
                        Graphics.FONT_SMALL,
                        errMsg,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );

                    var isTouch = System.getDeviceSettings().isTouchScreen;
                    var hintText = isTouch
                        ? "Swipe Right to retry"
                        : "Press BACK to retry";

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        cx,
                        hintY,
                        Graphics.FONT_XTINY,
                        hintText,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
