import Toybox.Graphics;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;

module Shared {
    module Logic {
        module PositionConfigure {
            function initializeGlobalLayout(dc as Graphics.Dc) as Void {
                var wCx = ArenaConfig.useArena(
                    ArenaType.CORE,
                    CoreArena.DataType.DISPLAY_WIDTH
                );

                if (wCx != null && wCx.get() == 0) {
                    var w = dc.getWidth();
                    var h = dc.getHeight();
                    wCx.set(w);
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_HEIGHT
                    ).set(h);
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_X
                    ).set(w / 2);
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_Y
                    ).set(h / 2);
                }
            }
        }
    }
}
