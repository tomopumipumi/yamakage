import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
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
import Features.SkyPlot.Components.MoonPathChart;
import Features.SkyPlot.Components.SkyPlotSunEvents;
import Features.SkyPlot.Components.SkyPlotMoonEvents;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.SkyPlotUiArena as skyA;
using Core.CustomContext as mycx;

module Features {
    module SkyPlot {
        class SkyPlotView extends WatchUi.View {
            private var _radius as Float = 0.0;
            private var _tickCount as Number = 0;
            private var _requestUpdate as Lang.Method;

            function initialize() {
                View.initialize();
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

                SkyPlotGrid.render(dc, cx, cy, _radius, nFont);
                AzimuthChart.render(dc, profiles, stepDeg, cx, cy, _radius);

                if (mode == 0) {
                    SunPathChart.render(dc, paths, cx, cy, _radius);
                    SkyPlotSunEvents.render(
                        dc,
                        paths,
                        cx,
                        cy,
                        _radius,
                        iconFont
                    );
                } else {
                    MoonPathChart.render(
                        dc,
                        paths,
                        cx,
                        cy,
                        _radius,
                        fraction,
                        phase
                    );
                    SkyPlotMoonEvents.render(
                        dc,
                        paths,
                        cx,
                        cy,
                        _radius,
                        iconFont
                    );
                }

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
