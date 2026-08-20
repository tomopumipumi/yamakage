import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Math;
import Shared.Logic.PositionConfigure;
import Features.Error.Components.ErrorMountains;
import Features.Error.Components.ErrorIcon;
import Features.Error.Components.ErrorMessage;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Error {
        class ErrorView extends WatchUi.View {
            private var _pulse as Float = 0.0;
            private var _onTimerTick as Lang.Method;

            function initialize() {
                View.initialize();
                _onTimerTick = method(:onTimerTick);
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(_onTimerTick);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_onTimerTick);
            }

            function onTimerTick() as Void {
                _pulse += 0.2;
                if (_pulse > Math.PI * 2) {
                    _pulse -= Math.PI * 2;
                }
                WatchUi.requestUpdate();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();

                var errMsg = MH.useString(coreA.LAST_ERROR).get();
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
