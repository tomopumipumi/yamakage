import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Math;
import Shared.Logic.PositionConfigure;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Error {
        // ==================================================
        // Props
        // ==================================================
        module ErrorProps {
            enum {
                W = 0, // Number
                H, // Number
                CX, // Number
                IS_ANIM_ON, // Boolean
                ERR_MSG, // String
                PULSE, // Float
                DATA_SIZE = 6
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class ErrorView extends WatchUi.View {
            // ID
            private const ON_ERROR_CHANGED_METHOD = :onErrorChanged;
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            private var _props as Array = new [ErrorProps.DATA_SIZE];

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[ErrorProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[ErrorProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();
                _props[ErrorProps.CX] = MH.useNumber(coreA.CENTER_X)
                    .init(0)
                    .req();
            }

            function onShow() as Void {
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _props[ErrorProps.IS_ANIM_ON] = animState.equals(
                    ToggleValues.ON
                );

                var err = MH.useString(coreA.LAST_ERROR).get();
                _props[ErrorProps.ERR_MSG] =
                    err != null ? err : "Unknown Error";

                _props[ErrorProps.PULSE] = 0.0;

                MH.watch(self, ON_ERROR_CHANGED_METHOD, [coreA.LAST_ERROR]);
                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
                MH.unwatch(self, ON_ERROR_CHANGED_METHOD);
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onErrorChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _props[ErrorProps.ERR_MSG] = vals[0] as String;
                    WatchUi.requestUpdate();
                }
            }

            function onTimerTick() as Void {
                var isAnimOn = _props[ErrorProps.IS_ANIM_ON] as Boolean;
                if (isAnimOn) {
                    var pulse = _props[ErrorProps.PULSE] as Float;
                    pulse += 0.2;
                    if (pulse > Math.PI * 2) {
                        pulse -= Math.PI * 2;
                    }
                    _props[ErrorProps.PULSE] = pulse;
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                ErrorRender.render(dc, _props);
            }
        }
    }
}
