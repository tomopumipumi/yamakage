import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core;
import Core.ApiSchema;
import Core.ApiSchema.DataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Shared.Ui.PageIndicator;
import Shared.Core.Page;
import Shared.Icons;
import Features.SkyPlot.Components.AzimuthChart;
import Features.SkyPlot.Components.HeadingMarker;
import Features.SkyPlot.Components.SkyPlotGrid;
import Features.SkyPlot.Components.SunPathChart;
import Features.SkyPlot.Components.SkyPlotSunEvents;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.SkyPlotUiArena as skyA;
using Core.CustomContext as mycx;

module Features {
    module SkyPlot {
        class SkyPlotView extends WatchUi.View {
            private var _shadowCx as mycx.PayloadContext;
            private var _radius as Float = 0.0;
            private var _tickCount as Number = 0;
            private var _requestUpdate as Lang.Method;

            function initialize() {
                View.initialize();
                _shadowCx = mycx.usePayload(coreA.CURRENT_SHADOW_DATA);
                _requestUpdate = method(:requestUpdate);
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(_requestUpdate);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_requestUpdate);
            }

            function requestUpdate() as Void {
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

                var fontCx = MH.useFont(skyA.N_FONT);
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

                var iconFontCx = MH.useFont(skyA.ICON_FONT);
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

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                var cy = MH.useNumber(coreA.CENTER_Y).init(0).req();

                var nFont = MH.useFont(skyA.N_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();

                var iconFont = MH.useFont(skyA.ICON_FONT)
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
                    Shared.Core.TOTAL_PAGES,
                    Page.SKYPLOT,
                    w,
                    h
                );
            }
        }
    }
}
