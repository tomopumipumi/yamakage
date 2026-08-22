import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Ui.PageIndicator;
import Shared.Core.Page;

import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarSun;
import Features.Radar.Components.RadarMoon;
import Features.Radar.Components.RadarBeam;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.RadarUiArena as radarA;
using Core.CustomContext as mycx;

module Features {
    module Radar {
        class RadarView extends WatchUi.View {
            private var _radius as Float = 0.0;
            private var _tickCount as Number = 0;
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
                _tickCount++;
                if (_tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
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

                var mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();
                var data = null;
                var stepDeg = 0;
                var profiles = null;
                var paths = null;
                var fraction = 1.0;
                var phase = 0.5;

                if (mode == 0) {
                    data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                    if (data != null) {
                        stepDeg = data[SunDataIndex.AZIMUTH_STEP] as Number;
                        profiles =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        paths = data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                    }
                } else {
                    data = mycx.useMoonPayload(coreA.MOON_SHADOW_DATA).get();
                    if (data != null) {
                        stepDeg = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        fraction = data[MoonDataIndex.FRACTION] as Float;
                        phase = data[MoonDataIndex.PHASE] as Float;
                        profiles =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        paths =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                    }
                }

                if (data == null) {
                    return;
                }

                var heading = CompassSensor.getHeadingDegrees();

                RadarGrid.render(dc, cx, cy, _radius, nFont);
                RadarArea.render(dc, profiles, stepDeg, cx, cy, _radius);

                if (mode == 0) {
                    RadarSun.render(dc, paths, cx, cy, _radius);
                } else {
                    RadarMoon.render(
                        dc,
                        paths,
                        cx,
                        cy,
                        _radius,
                        fraction,
                        phase
                    );
                }

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
