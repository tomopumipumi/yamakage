import Toybox.System;
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
import Shared.Icons;
import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaSunPath;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaSunEvents;
import Features.Panorama.Components.PanoramaLabels;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.PanoramaUiArena as panoramaA;
using Core.CustomContext as mycx;

module Features {
    module Panorama {
        class PanoramaView extends WatchUi.View {
            private var _shadowCx as mycx.PayloadContext;
            private const HEADING_KEY = :panorama_current_heading;
            private const MOUNTAIN_POINTS_KEY = :panorama_mountains_cache;
            private var _tickCount as Number = 0;

            private var _onTimerTickMethod as Lang.Method;
            private var _computeMountainPointsMethod as Lang.Method;

            function initialize() {
                View.initialize();
                _shadowCx = mycx.usePayload(coreA.CURRENT_SHADOW_DATA);
                _onTimerTickMethod = method(:onTimerTick);
                _computeMountainPointsMethod = method(:computeMountainPoints);
            }

            function onShow() {
                MH.SharedTimer.subscribe(_onTimerTickMethod);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_onTimerTickMethod);
                MH.destroy(HEADING_KEY);
                MH.destroy(:panorama_mountains_cache);
            }

            function onTimerTick() as Void {
                _tickCount = (_tickCount + 1) % 2;
                if (_tickCount == 0) {
                    var heading = CompassSensor.getHeadingDegrees();
                    if (heading == null) {
                        heading = 0.0;
                    }

                    MH.useFloat(HEADING_KEY).setSilent(heading);
                    WatchUi.requestUpdate();
                }
            }

            function requestUpdate() as Void {
                var heading = CompassSensor.getHeadingDegrees();
                if (heading == null) {
                    heading = 0.0;
                }
                MH.useFloat(HEADING_KEY).set(heading);
            }

            function computeMountainPoints(
                deps as Array
            ) as Array<Array<Number> > {
                var data = deps[0] as ApiSchema.ShadowDataPayload;
                var headingRaw = deps[1];
                var heading = headingRaw != null ? headingRaw.toFloat() : 0.0;
                var w = deps[2] as Number;
                var h = deps[3] as Number;

                var profiles =
                    data[DataIndex.AZIMUTH_PROFILES] as
                    ApiSchema.AzimuthProfilesArray;
                var step = data[DataIndex.AZIMUTH_STEP] as Number;

                return PanoramaLogic.getPanoramaPoints(
                    profiles,
                    step,
                    heading,
                    w,
                    h
                );
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();

                var iconFontCx = MH.useFont(panoramaA.ICON_FONT);
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
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                var iconFont = MH.useFont(panoramaA.ICON_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                Components.PanoramaGrid.render(dc, w, h);

                var data = _shadowCx.get();
                if (data == null) {
                    return;
                }

                var sunPaths =
                    data[DataIndex.SUN_PATHS] as ApiSchema.SunPathArray;
                var heading = MH.useFloat(HEADING_KEY).init(0.0).req();

                PanoramaSunPath.render(dc, sunPaths, heading, w, h);

                var mountainPoints =
                    MH.useComputed(
                        MOUNTAIN_POINTS_KEY,
                        [
                            coreA.CURRENT_SHADOW_DATA,
                            HEADING_KEY,
                            coreA.DISPLAY_WIDTH,
                            coreA.DISPLAY_HEIGHT
                        ],
                        _computeMountainPointsMethod
                    ).req() as Array<Array<Number> >;

                PanoramaMountains.render(dc, mountainPoints, h);

                PanoramaSunEvents.render(dc, sunPaths, heading, w, h, iconFont);

                PanoramaLabels.render(dc, heading, w, h, cx);

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.PANORAMA,
                    w,
                    h
                );
            }
        }
    }
}
