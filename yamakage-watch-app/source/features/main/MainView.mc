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
import Features.Main.Components.MainBackground;
import Features.Main.Components.MainGpsStatus;
import Features.Main.Components.MainTitle;
import Features.Main.Components.MainStartAction;
import Features.Main.Components.MainSunAnimation;
import Features.Main.Components.MainTargetSelector;
import Features.Main.Components.MainSettingsButton;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.MainUiArena as mainA;

module Features {
    module Main {
        class MainView extends WatchUi.View {
            private var _tickCount as Number = 0;

            function initialize() {
                View.initialize();
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(self, :onTimerTick);
                MH.LocationHook.subscribe(self, :onPositionUpdate);
                updateGpsState();
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :onTimerTick);
                MH.LocationHook.unsubscribe(self, :onPositionUpdate);
                MH.destroy(:main_sun_progress);
            }

            function onTimerTick() as Void {
                _tickCount++;
                if (_tickCount % 10 == 0) {
                    updateGpsState();
                }

                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                var isAnimOn = animState.equals(ToggleValues.ON);

                if (isAnimOn) {
                    var progress = MH.useFloat(:main_sun_progress)
                        .init(0.0)
                        .req();
                    progress += 0.005;
                    if (progress > 1.0) {
                        progress -= 1.0;
                    }

                    MH.useFloat(:main_sun_progress).set(progress);
                } else {
                    MH.useFloat(:main_sun_progress).set(0.5);
                }
            }

            function updateGpsState() as Void {
                MH.useString(mainA.GPS_TEXT).set(
                    LocationSensor.getGpsStatusString()
                );
                MH.useColor(mainA.GPS_COLOR).set(
                    LocationSensor.getGpsStatusColor()
                );
                MH.useBoolean(mainA.IS_GPS_READY).set(
                    LocationSensor.getPosition() != null
                );
            }

            function onPositionUpdate(info as Position.Info) as Void {
                updateGpsState();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var titleFontCx = MH.useFont(mainA.TITLE_FONT);

                var startBtnFontCx = MH.useFont(mainA.START_BTN_FONT);
                var startBtnWidthCx = MH.useNumber(mainA.START_BTN_WIDTH).init(
                    0
                );
                var startBtnHeightCx = MH.useNumber(
                    mainA.START_BTN_HEIGHT
                ).init(0);

                if (titleFontCx.get() == null or startBtnFontCx.get() == null) {
                    var startBtnWidth = (w * 0.5).toNumber();
                    var startBtnHeight = (h * 0.2).toNumber();

                    startBtnWidthCx.set(startBtnWidth);
                    startBtnHeightCx.set(startBtnHeight);

                    titleFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "YAMAKAGE",
                            (w * 0.8).toNumber(),
                            (h * 0.2).toNumber()
                        )
                    );
                    startBtnFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "START",
                            startBtnWidth,
                            startBtnHeight
                        )
                    );
                }
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();

                var titleFont = MH.useFont(mainA.TITLE_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();
                var startBtnFont = MH.useFont(mainA.START_BTN_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();
                var startBtnWidth = MH.useNumber(mainA.START_BTN_WIDTH)
                    .init(0)
                    .req();
                var startBtnHeight = MH.useNumber(mainA.START_BTN_HEIGHT)
                    .init(0)
                    .req();

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var gpsText = MH.useString(mainA.GPS_TEXT)
                    .init("GPS: Searching...")
                    .req();
                var gpsColor = MH.useColor(mainA.GPS_COLOR)
                    .init(Graphics.COLOR_DK_GRAY)
                    .req();
                var isGpsReady = MH.useBoolean(mainA.IS_GPS_READY)
                    .init(false)
                    .req();
                var progress = MH.useFloat(:main_sun_progress)
                    .init(0.0)
                    .req();
                var mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                MainSunAnimation.render(dc, progress, w, h, cx, mode);
                MainBackground.render(dc, w, h);

                var selectorX = (w * 0.85).toNumber();
                var selectorY = (h * 0.35).toNumber();
                MainTargetSelector.render(dc, selectorX, selectorY, mode);

                var gpsY = (h * 0.1).toNumber();
                MainGpsStatus.render(dc, cx, gpsY, gpsText, gpsColor);
                var titleY = (h * 0.25).toNumber();
                MainTitle.render(dc, cx, titleY, titleFont);
                var btnY = (h * 0.8).toNumber();
                MainStartAction.render(
                    dc,
                    cx,
                    btnY,
                    startBtnWidth,
                    startBtnHeight,
                    startBtnFont,
                    isGpsReady,
                    mode
                );
            }
        }
    }
}
