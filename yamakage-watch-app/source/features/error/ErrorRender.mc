import Toybox.Lang;
import Toybox.Graphics;

import Features.Error.Components.ErrorMountains;
import Features.Error.Components.ErrorIcon;
import Features.Error.Components.ErrorMessage;

module Features {
    module Error {
        module ErrorRender {
            function render(dc as Graphics.Dc, props as Array) as Void {
                var w = props[ErrorProps.W] as Number;
                var h = props[ErrorProps.H] as Number;
                var cx = props[ErrorProps.CX] as Number;
                var errMsg = props[ErrorProps.ERR_MSG] as String;
                var pulse = props[ErrorProps.PULSE] as Float;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                ErrorMountains.render(dc, w, h);

                var iconY = (h * 0.35).toNumber();
                ErrorIcon.render(dc, cx, iconY, pulse);

                var msgY = (h * 0.55).toNumber();
                var hintY = (h * 0.75).toNumber();
                ErrorMessage.render(dc, cx, msgY, hintY, errMsg);
            }
        }
    }
}
