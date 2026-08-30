import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Math;
import Shared.Logic.PositionConfigure;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;
import Features.Error.Components.ErrorMountains;
import Features.Error.Components.ErrorIcon;
import Features.Error.Components.ErrorMessage;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Error {
        class ErrorView extends WatchUi.View {
            // ==================================================
            // ID
            // ==================================================
            private const ON_ERROR_CHANGED_METHOD = :onErrorChanged;
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            // ==================================================
            // Cash
            // ==================================================
            private var _pulse as Float = 0.0;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;

            private var _isAnimOn as Boolean = true;
            private var _errMsg as String = "Unknown Error";

            // ==================================================
            // Subscribe Method
            // ==================================================
            function onErrorChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _errMsg = vals[0] as String;
                    WatchUi.requestUpdate();
                }
            }

            function onTimerTick() as Void {
                if (_isAnimOn) {
                    _pulse += 0.2;
                    if (_pulse > Math.PI * 2) {
                        _pulse -= Math.PI * 2;
                    }
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Override Method
            // ==================================================
            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                _cx = MH.useNumber(coreA.CENTER_X).init(0).req();
            }

            function onShow() as Void {
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _isAnimOn = animState.equals(ToggleValues.ON);

                var err = MH.useString(coreA.LAST_ERROR).get();
                _errMsg = err != null ? err : "Unknown Error";

                MH.watch(self, ON_ERROR_CHANGED_METHOD, [coreA.LAST_ERROR]);

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
                MH.unwatch(self, ON_ERROR_CHANGED_METHOD);
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                ErrorMountains.render(dc, _w, _h);

                var iconY = (_h * 0.35).toNumber();
                ErrorIcon.render(dc, _cx, iconY, _pulse);

                var msgY = (_h * 0.55).toNumber();
                var hintY = (_h * 0.75).toNumber();
                ErrorMessage.render(dc, _cx, msgY, hintY, _errMsg);
            }
        }
    }
}
