import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Position;
import Toybox.Timer;

import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Hal.Sensor.LocationSensor;
import Features.Main.Components.MainBackground;
import Features.Main.Components.MainGpsStatus;
import Features.Main.Components.MainTitle;
import Features.Main.Components.MainStartAction;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.MainUiArena as mainA;

module Features {
    module Main {
        class MainView extends WatchUi.View {
            private var _tickCount as Number = 0;
            private var _onPositionUpdate as Lang.Method;
            private var _onTimerTick as Lang.Method;

            function initialize() {
                View.initialize();
                _onPositionUpdate = method(:onPositionUpdate);
                _onTimerTick = method(:onTimerTick);
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(_onTimerTick);
                MH.LocationHook.subscribe(_onPositionUpdate);
                updateGpsState();
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_onTimerTick);
                MH.LocationHook.unsubscribe(_onPositionUpdate);
            }

            function onTimerTick() as Void {
                _tickCount++;
                if (_tickCount % 10 == 0) {
                    updateGpsState();
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
                var btnFontCx = MH.useFont(mainA.BTN_FONT);
                var btnWidthCx = MH.useNumber(mainA.BTN_WIDTH).init(0);
                var btnHeightCx = MH.useNumber(mainA.BTN_HEIGHT).init(0);

                if (titleFontCx.get() == null) {
                    var btnWidth = (w * 0.5).toNumber();
                    var btnHeight = (h * 0.2).toNumber();
                    btnWidthCx.set(btnWidth);
                    btnHeightCx.set(btnHeight);
                    titleFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "YAMAKAGE",
                            (w * 0.8).toNumber(),
                            (h * 0.2).toNumber()
                        )
                    );
                    btnFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "START",
                            btnWidth,
                            btnHeight
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
                var btnFont = MH.useFont(mainA.BTN_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();
                var btnWidth = MH.useNumber(mainA.BTN_WIDTH).init(0).req();
                var btnHeight = MH.useNumber(mainA.BTN_HEIGHT).init(0).req();

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

                MainBackground.render(dc, w, h);
                var gpsY = (h * 0.1).toNumber();
                MainGpsStatus.render(dc, cx, gpsY, gpsText, gpsColor);
                var titleY = (h * 0.25).toNumber();
                MainTitle.render(dc, cx, titleY, titleFont);
                var btnY = (h * 0.8).toNumber();
                MainStartAction.render(
                    dc,
                    cx,
                    btnY,
                    btnWidth,
                    btnHeight,
                    btnFont,
                    isGpsReady
                );
            }
        }
    }
}
