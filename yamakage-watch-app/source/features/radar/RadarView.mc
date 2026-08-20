import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core.ApiSchema;
import Core.ApiSchema.DataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Ui.PageIndicator;
import Shared.Core.Page;
import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarSun;
import Features.Radar.Components.RadarBeam;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.RadarUiArena as radarA;
using Core.CustomContext as mycx;

module Features {
    module Radar {
        class RadarView extends WatchUi.View {
            private var _shadowCx as mycx.PayloadContext;
            private var _radius as Float = 0.0;
            private var _tickCount as Number = 0;

            private var _onTimerTick as Lang.Method;

            function initialize() {
                View.initialize();
                _shadowCx = mycx.usePayload(coreA.CURRENT_SHADOW_DATA);
                _onTimerTick = method(:onTimerTick);
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(_onTimerTick);
            }
            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_onTimerTick);
            }
            function onTimerTick() as Void {
                _tickCount++;
                if (_tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
            }
            function requestUpdate() as Void {
                WatchUi.requestUpdate();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();

                _radius = ((w < h ? w : h) / 2.0) * 0.75;

                var fontCx = MH.useFont(radarA.N_FONT);
                if (fontCx.get() == null) {
                    fontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "N",
                            (w * 0.2).toNumber(),
                            (h * 0.1).toNumber()
                        )
                    );
                }
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                var cy = MH.useNumber(coreA.CENTER_Y).init(0).req();

                var nFont = MH.useFont(radarA.N_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();

                var rawData = _shadowCx.get();
                if (rawData == null) {
                    return;
                }

                var stepDeg = rawData[DataIndex.AZIMUTH_STEP];
                var profiles =
                    rawData[DataIndex.AZIMUTH_PROFILES] as
                    ApiSchema.AzimuthProfilesArray;
                var sunPaths =
                    rawData[DataIndex.SUN_PATHS] as ApiSchema.SunPathArray;
                var heading = CompassSensor.getHeadingDegrees();

                RadarGrid.render(dc, cx, cy, _radius, nFont);
                RadarArea.render(dc, profiles, stepDeg, cx, cy, _radius);
                RadarSun.render(dc, sunPaths, cx, cy, _radius);

                if (heading != null) {
                    RadarBeam.render(
                        dc,
                        heading,
                        profiles,
                        stepDeg,
                        cx,
                        cy,
                        _radius
                    );
                }

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.RADAR,
                    w,
                    h
                );
            }
        }
    }
}
