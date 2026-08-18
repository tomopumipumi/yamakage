import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.SkyPlotUiArena;
import Core.ApiSchema;
import Core.ApiSchema.DataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Shared.Ui.PageIndicator;
import Shared.Core.Router;
import Shared.Icons;
import Features.SkyPlot.Components.AzimuthChart;
import Features.SkyPlot.Components.HeadingMarker;
import Features.SkyPlot.Components.SkyPlotGrid;
import Features.SkyPlot.Components.SunPathChart;
import Features.SkyPlot.Components.SkyPlotSunEvents;

module Features {
    module SkyPlot {
        class SkyPlotView extends WatchUi.View {
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
                    ArenaType.SKYPLOT_UI,
                    SkyPlotUiArena.DataType.N_FONT
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

                var iconFontCx = ArenaConfig.useArena(
                    ArenaType.SKYPLOT_UI,
                    SkyPlotUiArena.DataType.ICON_FONT
                );
                if (iconFontCx.get() == null) {
                    var iconFonts =
                        [
                            WatchUi.loadResource(Rez.Fonts.IconFont40) as
                                Graphics.FontType,
                            WatchUi.loadResource(Rez.Fonts.IconFont48) as
                                Graphics.FontType,
                            WatchUi.loadResource(Rez.Fonts.IconFont62) as
                                Graphics.FontType,
                            WatchUi.loadResource(Rez.Fonts.IconFont92) as
                                Graphics.FontType
                        ] as Array<Graphics.FontType>;

                    iconFontCx.set(
                        FontManager.findBestFontFromList(
                            dc,
                            Icons.ICON_SUNRISE,
                            (w * 0.1).toNumber(),
                            (h * 0.1).toNumber(),
                            iconFonts
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
                        ArenaType.SKYPLOT_UI,
                        SkyPlotUiArena.DataType.N_FONT
                    ).get() as Graphics.FontType;

                var iconFont =
                    ArenaConfig.useArena(
                        ArenaType.SKYPLOT_UI,
                        SkyPlotUiArena.DataType.ICON_FONT
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

                SkyPlotGrid.render(dc, cx, cy, _radius, nFont);

                SunPathChart.render(dc, sunPaths, cx, cy, _radius);

                AzimuthChart.render(dc, profiles, stepDeg, cx, cy, _radius);

                SkyPlotSunEvents.render(
                    dc,
                    sunPaths,
                    cx,
                    cy,
                    _radius,
                    iconFont
                );

                if (heading != null) {
                    HeadingMarker.render(
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
                    Router.Page.SKYPLOT,
                    w,
                    h
                );
            }
        }
    }
}
