import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.RadarUiArena;
import Core.ApiSchema;
import Core.ApiSchema.DataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Ui.PageIndicator;
import Shared.Core.Router;

import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarSun;
import Features.Radar.Components.RadarBeam;

module Features {
    module Radar {
        class RadarView extends WatchUi.View {
            private var _timer as Timer.Timer;
            private var _shadowCx as ArenaConfig.Context;
            private var _radius as Float = 0.0;

            function initialize() {
                View.initialize();
                _timer = new Timer.Timer();
                _shadowCx = ArenaConfig.useArena(
                    ArenaType.CORE,
                    CoreArena.DataType.CURRENT_SHADOW_DATA
                );
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
                var w =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_WIDTH
                    ).get() as Number;
                var h =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_HEIGHT
                    ).get() as Number;

                _radius = ((w < h ? w : h) / 2.0) * 0.75;

                var fontCx = ArenaConfig.useArena(
                    ArenaType.RADAR_UI,
                    RadarUiArena.DataType.N_FONT
                );
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

            function onShow() as Void {
                _timer.start(method(:requestUpdate), 200, true);
            }
            function onHide() as Void {
                _timer.stop();
            }
            function requestUpdate() as Void {
                WatchUi.requestUpdate();
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var w =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_WIDTH
                    ).get() as Number;
                var h =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_HEIGHT
                    ).get() as Number;
                var cx =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_X
                    ).get() as Number;
                var cy =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_Y
                    ).get() as Number;

                var nFont =
                    ArenaConfig.useArena(
                        ArenaType.RADAR_UI,
                        RadarUiArena.DataType.N_FONT
                    ).get() as Graphics.FontType;

                var rawData = _shadowCx.get() as ApiSchema.ShadowDataPayload?;
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
                    Router.TOTAL_PAGES,
                    Router.Page.RADAR,
                    w,
                    h
                );
            }
        }
    }
}
