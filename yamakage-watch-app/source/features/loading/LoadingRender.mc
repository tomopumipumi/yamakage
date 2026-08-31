import Toybox.Lang;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;

import Features.Loading.Components.LoadingSun;
import Features.Loading.Components.LoadingMoon;
import Features.Loading.Components.LoadingMountains;

module Features {
    module Loading {
        module LoadingRender {
            function render(dc as Graphics.Dc, props as Array) as Void {
                var w = props[LoadingProps.W] as Number;
                var h = props[LoadingProps.H] as Number;
                var cx = props[LoadingProps.CX] as Number;
                var font = props[LoadingProps.FONT] as Graphics.FontType?;

                var mode = props[LoadingProps.MODE] as Number;
                var msg = props[LoadingProps.MSG] as String;
                var angle = props[LoadingProps.ANGLE] as Float;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var objY = (h * 0.35).toNumber();

                switch (mode) {
                    case TargetMode.SUN:
                        LoadingSun.render(dc, cx, objY, angle);
                        break;

                    case TargetMode.MOON:
                        LoadingMoon.render(dc, cx, objY, angle);
                        break;
                }

                LoadingMountains.render(dc, w, h);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                if (font != null) {
                    dc.drawText(
                        cx,
                        (h * 0.7).toNumber(),
                        font,
                        msg,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
