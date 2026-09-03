import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Hal.Sensor.LocationSensor;

using MonkeyHooks as MH;
using MonkeyHooks.Touchable as MHTouchable;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.MainUiArena as mainA;

module Features {
    module Main {
        // ==================================================
        // Props
        // ==================================================
        module MainProps {
            enum {
                W = 0, // Number
                H, // Number
                CX, // Number
                TITLE_FONT, // Graphics.FontType
                START_BTN_FONT, // Graphics.FontType
                START_BTN_WIDTH, // Number
                START_BTN_HEIGHT, // Number
                MODE, // Number (Shared.Core.Enums.TargetMode)
                IS_ANIM_ON, // Boolean
                PROGRESS, // Float
                SPARKLE_BUFFER, // Array?
                GPS_TEXT, // String
                GPS_COLOR, // Graphics.ColorType
                IS_GPS_READY, // Boolean
                DATA_SIZE = 14
            }
        }

        // ==================================================
        // Features Consts
        // ==================================================
        const MAIN_SUN_PROGRESS_KEY = :main_sun_progress;
        const MAIN_SPARKLES_KEY = :main_sparkles;
        const MAIN_START_BUTTON_KEY = :main_start_button;
        const ON_TARGET_MODE_CHANGED_METHOD = :onTargetModeChanged;
        const ON_TIMER_TICK_METHOD = :onTimerTick;
        const ON_POSITION_UPDATE_METHOD = :onPositionUpdate;

        // ==================================================
        // View Container
        // ==================================================
        class MainView extends WatchUi.View {
            private var _props as Array = new [MainProps.DATA_SIZE];

            private var _tickCount as Number = 0;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[MainProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[MainProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();
                _props[MainProps.CX] = MH.useNumber(coreA.CENTER_X)
                    .init(0)
                    .req();

                var w = _props[MainProps.W] as Number;
                var h = _props[MainProps.H] as Number;

                var titleFontCx = MH.useFont(mainA.TITLE_FONT);
                var startBtnFontCx = MH.useFont(mainA.START_BTN_FONT);
                var startBtnWidthCx = MH.useNumber(mainA.START_BTN_WIDTH).init(
                    0
                );
                var startBtnHeightCx = MH.useNumber(
                    mainA.START_BTN_HEIGHT
                ).init(0);

                if (titleFontCx.get() == null or startBtnFontCx.get() == null) {
                    var btnW = (w * 0.5).toNumber();
                    var btnH = (h * 0.2).toNumber();

                    startBtnWidthCx.set(btnW);
                    startBtnHeightCx.set(btnH);

                    titleFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "YAMAKAGE",
                            (w * 0.8).toNumber(),
                            (h * 0.2).toNumber()
                        )
                    );
                    startBtnFontCx.set(
                        FontManager.findBestFont(dc, "START", btnW, btnH)
                    );
                }

                _props[MainProps.TITLE_FONT] = titleFontCx.req();
                _props[MainProps.START_BTN_FONT] = startBtnFontCx.req();
                _props[MainProps.START_BTN_WIDTH] = startBtnWidthCx.req();
                _props[MainProps.START_BTN_HEIGHT] = startBtnHeightCx.req();
            }

            function onShow() as Void {
                _props[MainProps.MODE] = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _props[MainProps.IS_ANIM_ON] = animState.equals(
                    ToggleValues.ON
                );

                _props[MainProps.PROGRESS] = MH.useFloat(MAIN_SUN_PROGRESS_KEY)
                    .init(0.0)
                    .req();
                _props[MainProps.SPARKLE_BUFFER] = MH.useArrayBuffer(
                    MAIN_SPARKLES_KEY,
                    45
                ).req();

                _props[MainProps.GPS_TEXT] = "GPS: Searching...";
                _props[MainProps.GPS_COLOR] = Graphics.COLOR_DK_GRAY;
                _props[MainProps.IS_GPS_READY] = false;
                _updateGpsState();

                MH.watch(self, ON_TARGET_MODE_CHANGED_METHOD, [
                    coreA.TARGET_MODE
                ]);
                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
                MH.LocationHook.subscribe(self, ON_POSITION_UPDATE_METHOD);

                if (System.getDeviceSettings().isTouchScreen) {
                    _touchableSetting();
                }
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
                MH.LocationHook.unsubscribe(self, ON_POSITION_UPDATE_METHOD);
                MH.unwatch(self, ON_TARGET_MODE_CHANGED_METHOD);

                MH.useFloat(MAIN_SUN_PROGRESS_KEY).setSilent(
                    _props[MainProps.PROGRESS] as Float
                );

                if (System.getDeviceSettings().isTouchScreen) {
                    MHTouchable.clear();
                }
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onTargetModeChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _props[MainProps.MODE] = vals[0] as Number;
                }
            }

            function onTimerTick() as Void {
                _tickCount++;
                if (_tickCount % 10 == 0) {
                    _updateGpsState();
                }

                var isAnimOn = _props[MainProps.IS_ANIM_ON] as Boolean;
                var progress = _props[MainProps.PROGRESS] as Float;

                if (isAnimOn) {
                    progress += 0.005;
                    if (progress > 1.0) {
                        progress -= 1.0;
                    }
                    _props[MainProps.PROGRESS] = progress;
                    WatchUi.requestUpdate();
                } else {
                    if (progress != 0.5) {
                        _props[MainProps.PROGRESS] = 0.5;
                        WatchUi.requestUpdate();
                    }
                }
            }

            function onPositionUpdate(info as Position.Info) as Void {
                _updateGpsState();
            }

            // ==================================================
            // Private Methods
            // ==================================================
            private function _touchableSetting() as Void {
                MHTouchable.clear();

                var h = _props[MainProps.H] as Number;

                var btnY = (h * 0.8).toNumber();
                var btnW = _props[MainProps.START_BTN_WIDTH] as Number;
                var btnH = _props[MainProps.START_BTN_HEIGHT] as Number;
                var cx = _props[MainProps.CX] as Number;

                var btnTopX = cx - btnW / 2;
                var btnTopY = btnY - btnH / 2;

                MHTouchable.registerRect(
                    MAIN_START_BUTTON_KEY,
                    btnTopX,
                    btnTopY,
                    btnW,
                    btnH
                );
            }

            private function _updateGpsState() as Void {
                var newText = LocationSensor.getGpsStatusString();
                var newColor = LocationSensor.getGpsStatusColor();
                var newReady = LocationSensor.getPosition() != null;

                var isChanged = false;

                var currentText = _props[MainProps.GPS_TEXT] as String;
                if (!currentText.equals(newText)) {
                    _props[MainProps.GPS_TEXT] = newText;
                    isChanged = true;
                }

                if (_props[MainProps.GPS_COLOR] != newColor) {
                    _props[MainProps.GPS_COLOR] = newColor;
                    isChanged = true;
                }

                if (_props[MainProps.IS_GPS_READY] != newReady) {
                    _props[MainProps.IS_GPS_READY] = newReady;
                    isChanged = true;
                }

                if (isChanged) {
                    MH.useString(mainA.GPS_TEXT).setSilent(newText);
                    MH.useColor(mainA.GPS_COLOR).setSilent(newColor);
                    MH.useBoolean(mainA.IS_GPS_READY).setSilent(newReady);

                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                MainRender.render(dc, _props);
            }
        }
    }
}
