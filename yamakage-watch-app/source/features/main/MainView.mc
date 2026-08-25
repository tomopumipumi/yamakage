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

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;
            private var _titleFont as Graphics.FontType?;
            private var _startBtnFont as Graphics.FontType?;
            private var _startBtnWidth as Number = 0;
            private var _startBtnHeight as Number = 0;

            private var _isAnimOn as Boolean = true;
            private var _mode as Number = TargetMode.SUN;

            private var _progress as Float = 0.0;
            private var _gpsText as String = "GPS: Searching...";
            private var _gpsColor as Graphics.ColorType =
                Graphics.COLOR_DK_GRAY;
            private var _isGpsReady as Boolean = false;
            private var _sparkleBuffer as Array?;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                _cx = MH.useNumber(coreA.CENTER_X).init(0).req();

                var titleFontCx = MH.useFont(mainA.TITLE_FONT);
                var startBtnFontCx = MH.useFont(mainA.START_BTN_FONT);
                var startBtnWidthCx = MH.useNumber(mainA.START_BTN_WIDTH).init(
                    0
                );
                var startBtnHeightCx = MH.useNumber(
                    mainA.START_BTN_HEIGHT
                ).init(0);

                if (titleFontCx.get() == null or startBtnFontCx.get() == null) {
                    _startBtnWidth = (_w * 0.5).toNumber();
                    _startBtnHeight = (_h * 0.2).toNumber();

                    startBtnWidthCx.set(_startBtnWidth);
                    startBtnHeightCx.set(_startBtnHeight);

                    titleFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "YAMAKAGE",
                            (_w * 0.8).toNumber(),
                            (_h * 0.2).toNumber()
                        )
                    );
                    startBtnFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "START",
                            _startBtnWidth,
                            _startBtnHeight
                        )
                    );
                } else {
                    _startBtnWidth = startBtnWidthCx.req();
                    _startBtnHeight = startBtnHeightCx.req();
                }

                _titleFont = titleFontCx.req();
                _startBtnFont = startBtnFontCx.req();
            }

            function onShow() as Void {
                _mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _isAnimOn = animState.equals(ToggleValues.ON);
                _progress = MH.useFloat(:main_sun_progress)
                    .init(0.0)
                    .req();
                _sparkleBuffer = MH.useArrayBuffer(:main_sparkles, 45).req();

                updateGpsState();

                MH.watch(self, :onTargetModeChanged, [coreA.TARGET_MODE]);
                MH.watch(self, :onAnimConfigChanged, [SettingIds.ANIM_ENABLED]);

                MH.SharedTimer.subscribe(self, :onTimerTick);
                MH.LocationHook.subscribe(self, :onPositionUpdate);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :onTimerTick);
                MH.LocationHook.unsubscribe(self, :onPositionUpdate);

                MH.unwatch(self, :onTargetModeChanged);
                MH.unwatch(self, :onAnimConfigChanged);

                MH.useFloat(:main_sun_progress).setSilent(_progress);
            }

            function onTargetModeChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _mode = vals[0] as Number;
                }
            }

            function onAnimConfigChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    var animState = vals[0] as String;
                    _isAnimOn = animState.equals(ToggleValues.ON);
                }
            }

            function onTimerTick() as Void {
                _tickCount++;
                if (_tickCount % 10 == 0) {
                    updateGpsState();
                }

                if (_isAnimOn) {
                    _progress += 0.005;
                    if (_progress > 1.0) {
                        _progress -= 1.0;
                    }
                    WatchUi.requestUpdate();
                } else {
                    if (_progress != 0.5) {
                        _progress = 0.5;
                        WatchUi.requestUpdate();
                    }
                }
            }

            function updateGpsState() as Void {
                var newText = LocationSensor.getGpsStatusString();
                var newColor = LocationSensor.getGpsStatusColor();
                var newReady = LocationSensor.getPosition() != null;

                var isChanged = false;
                if (!_gpsText.equals(newText)) {
                    _gpsText = newText;
                    isChanged = true;
                }
                if (_gpsColor != newColor) {
                    _gpsColor = newColor;
                    isChanged = true;
                }
                if (_isGpsReady != newReady) {
                    _isGpsReady = newReady;
                    isChanged = true;
                }

                if (isChanged) {
                    MH.useString(mainA.GPS_TEXT).setSilent(_gpsText);
                    MH.useColor(mainA.GPS_COLOR).setSilent(_gpsColor);
                    MH.useBoolean(mainA.IS_GPS_READY).setSilent(_isGpsReady);

                    WatchUi.requestUpdate();
                }
            }

            function onPositionUpdate(info as Position.Info) as Void {
                updateGpsState();
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                MainSunAnimation.render(
                    dc,
                    _progress,
                    _w,
                    _h,
                    _cx,
                    _mode,
                    _isAnimOn,
                    _sparkleBuffer
                );
                MainBackground.render(dc, _w, _h);

                var selectorX = (_w * 0.85).toNumber();
                var selectorY = (_h * 0.35).toNumber();
                MainTargetSelector.render(dc, selectorX, selectorY, _mode);

                var gpsY = (_h * 0.1).toNumber();
                MainGpsStatus.render(dc, _cx, gpsY, _gpsText, _gpsColor);

                var titleY = (_h * 0.25).toNumber();
                MainTitle.render(dc, _cx, titleY, _titleFont);

                var btnY = (_h * 0.8).toNumber();
                MainStartAction.render(
                    dc,
                    _cx,
                    btnY,
                    _startBtnWidth,
                    _startBtnHeight,
                    _startBtnFont,
                    _isGpsReady,
                    _mode
                );
            }
        }
    }
}
