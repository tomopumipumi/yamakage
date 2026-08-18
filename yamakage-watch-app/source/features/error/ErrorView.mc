import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Math;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Shared.Logic.PositionConfigure;

import Features.Error.Components.ErrorMountains;
import Features.Error.Components.ErrorIcon;
import Features.Error.Components.ErrorMessage;

module Features {
    module Error {
        class ErrorView extends WatchUi.View {
            private var _timer as Timer.Timer;
            private var _pulse as Float = 0.0;

            function initialize() {
                View.initialize();
                _timer = new Timer.Timer();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
            }

            function onShow() as Void {
                _timer.start(method(:onTimerTick), 100, true);
            }

            function onHide() as Void {
                _timer.stop();
            }

            function onTimerTick() as Void {
                _pulse += 0.2;
                if (_pulse > Math.PI * 2) {
                    _pulse -= Math.PI * 2;
                }
                WatchUi.requestUpdate();
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                var w =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_WIDTH
                    ).get() as Number;
                var h =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_HEIGHT
                    ).get() as Number;
                var cx =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_X
                    ).get() as Number;

                var errMsg =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.LAST_ERROR
                    ).get() as String?;
                if (errMsg == null) {
                    errMsg = "Unknown Error";
                }

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                ErrorMountains.render(dc, w, h);

                var iconY = (h * 0.35).toNumber();
                ErrorIcon.render(dc, cx, iconY, _pulse);

                var msgY = (h * 0.55).toNumber();
                var hintY = (h * 0.75).toNumber();
                ErrorMessage.render(dc, cx, msgY, hintY, errMsg);
            }
        }
    }
}
