import Toybox.Graphics;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Shared {
    module Logic {
        module PositionConfigure {
            function initializeGlobalLayout(dc as Graphics.Dc) as Void {
                var wCx = MH.useNumber(coreA.DISPLAY_WIDTH);

                if (wCx.get() == null) {
                    var w = dc.getWidth();
                    var h = dc.getHeight();
                    wCx.set(w);
                    MH.useNumber(coreA.DISPLAY_HEIGHT).set(h);
                    MH.useNumber(coreA.CENTER_X).set(w / 2);
                    MH.useNumber(coreA.CENTER_Y).set(h / 2);
                }
            }
        }
    }
}
