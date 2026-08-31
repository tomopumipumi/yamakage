import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Page;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.LoadingUiArena as loadA;

module Features {
    module Loading {
        // ==================================================
        // Props
        // ==================================================
        module LoadingProps {
            enum {
                W = 0, // Number
                H, // Number
                CX, // Number
                FONT, // Graphics.FontType?
                MODE, // Number (Shared.Core.Enums.TargetMode)
                IS_ANIM_ON, // Boolean
                MSG, // String
                ANGLE, // Float
                DATA_SIZE = 8
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class LoadingView extends WatchUi.View {
            // ID
            private const ON_STATE_CHANGED_METHOD = :onStateChanged;
            private const ON_MSG_TEXT_CHANGED_METHOD = :onMsgTextChanged;
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            private var _props as Array = new [LoadingProps.DATA_SIZE];

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[LoadingProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[LoadingProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();
                _props[LoadingProps.CX] = MH.useNumber(coreA.CENTER_X)
                    .init(0)
                    .req();

                var w = _props[LoadingProps.W] as Number;
                var h = _props[LoadingProps.H] as Number;

                var fontCx = MH.useFont(loadA.MSG_FONT);
                if (fontCx.get() == null) {
                    fontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "Calculating...",
                            (w * 0.9).toNumber(),
                            (h * 0.2).toNumber()
                        )
                    );
                }
                _props[LoadingProps.FONT] = fontCx.get() as Graphics.FontType;
            }

            function onShow() as Void {
                _props[LoadingProps.MODE] = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _props[LoadingProps.IS_ANIM_ON] = animState.equals(
                    ToggleValues.ON
                );

                _props[LoadingProps.MSG] = MH.useString(loadA.MSG_TEXT)
                    .init("Loading...")
                    .req();
                _props[LoadingProps.ANGLE] = 0.0;

                var targetDataKey =
                    _props[LoadingProps.MODE] == TargetMode.SUN
                        ? coreA.SUN_SHADOW_DATA
                        : coreA.MOON_SHADOW_DATA;

                MH.watch(self, ON_STATE_CHANGED_METHOD, [
                    targetDataKey,
                    coreA.LAST_ERROR
                ]);
                MH.watch(self, ON_MSG_TEXT_CHANGED_METHOD, [loadA.MSG_TEXT]);

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
                MH.unwatch(self, ON_STATE_CHANGED_METHOD);
                MH.unwatch(self, ON_MSG_TEXT_CHANGED_METHOD);
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onTimerTick() as Void {
                var isAnimOn = _props[LoadingProps.IS_ANIM_ON] as Boolean;
                if (isAnimOn) {
                    var angle = _props[LoadingProps.ANGLE] as Float;
                    angle += 0.1;
                    if (angle > Math.PI * 2) {
                        angle -= Math.PI * 2;
                    }
                    _props[LoadingProps.ANGLE] = angle;
                    WatchUi.requestUpdate();
                }
            }

            function onStateChanged(values as Array) as Void {
                var data = values[0];
                var err = values[1];

                var pageNum =
                    data != null
                        ? Page.PANORAMA
                        : err != null
                          ? Page.ERROR
                          : null;

                if (pageNum != null) {
                    MH.Router.switchTo(pageNum, WatchUi.SLIDE_LEFT);
                }
            }

            function onMsgTextChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _props[LoadingProps.MSG] = vals[0] as String;
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                LoadingRender.render(dc, _props);
            }
        }
    }
}
