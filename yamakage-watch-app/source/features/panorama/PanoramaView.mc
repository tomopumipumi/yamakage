import Toybox.System;
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
import Shared.Icons;

import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaSunPath;
import Features.Panorama.Components.PanoramaMoonPath;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaSunEvents;
import Features.Panorama.Components.PanoramaMoonEvents;
import Features.Panorama.Components.PanoramaLabels;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.PanoramaUiArena as panoramaA;
using Core.CustomContext as mycx;

module Features {
    module Panorama {
        class PanoramaView extends WatchUi.View {
            private const HEADING_KEY = :panorama_current_heading;
            private const MOUNTAIN_POINTS_KEY = :panorama_mountains_cache;
            private var _tickCount as Number = 0;
            private var _onTimerTickMethod as Lang.Method;
            private var _computeMountainPointsMethod as Lang.Method;

            function initialize() {
                View.initialize();
                _onTimerTickMethod = method(:onTimerTick);
                _computeMountainPointsMethod = method(:computeMountainPoints);
            }

            function onShow() {
                MH.SharedTimer.subscribe(_onTimerTickMethod);
            }
            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_onTimerTickMethod);
                MH.destroy(HEADING_KEY);
                MH.destroy(MOUNTAIN_POINTS_KEY);
            }

            function onTimerTick() as Void {
                _tickCount = (_tickCount + 1) % 2;
                if (_tickCount == 0) {
                    var heading = CompassSensor.getHeadingDegrees();
                    MH.useFloat(HEADING_KEY).setSilent(
                        heading != null ? heading : 0.0
                    );
                    WatchUi.requestUpdate();
                }
            }

            function computeMountainPoints(
                deps as Array
            ) as Array<Array<Number> > {
                var data = deps[0] as Array?;
                var heading = deps[1] != null ? deps[1].toFloat() : 0.0;
                var w = deps[2] as Number;
                var h = deps[3] as Number;
                var mode = deps[4] as Number;

                if (data == null) {
                    return [] as Array<Array<Number> >;
                }

                var profiles;
                var step;

                if (mode == 0) {
                    profiles =
                        data[SunDataIndex.PROFILES] as
                        ApiSchema.AzimuthProfilesArray;
                    step = data[SunDataIndex.AZIMUTH_STEP] as Number;
                } else {
                    profiles =
                        data[MoonDataIndex.PROFILES] as
                        ApiSchema.AzimuthProfilesArray;
                    step = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                }

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
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                var mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();

                var iconFont = MH.useFont(panoramaA.ICON_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();

                var paths = null;
                var fraction = 1.0;
                var phase = 0.5;
                var targetDataKey;

                if (mode == 0) {
                    targetDataKey = coreA.SUN_SHADOW_DATA;
                    var data = mycx.useSunPayload(targetDataKey).get();
                    if (data == null) {
                        return;
                    }
                    paths = data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                } else {
                    targetDataKey = coreA.MOON_SHADOW_DATA;
                    var data = mycx.useMoonPayload(targetDataKey).get();
                    if (data == null) {
                        return;
                    }
                    paths = data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                    fraction = data[MoonDataIndex.FRACTION] as Float;
                    phase = data[MoonDataIndex.PHASE] as Float;
                }

                var heading = MH.useFloat(HEADING_KEY).init(0.0).req();

                PanoramaGrid.render(dc, w, h);

                if (mode == 0) {
                    PanoramaSunPath.render(dc, paths, heading, w, h);
                } else {
                    PanoramaMoonPath.render(
                        dc,
                        paths,
                        heading,
                        w,
                        h,
                        fraction,
                        phase
                    );
                }

                var mountainPoints =
                    MH.useComputed(
                        MOUNTAIN_POINTS_KEY,
                        [
                            targetDataKey,
                            HEADING_KEY,
                            coreA.DISPLAY_WIDTH,
                            coreA.DISPLAY_HEIGHT,
                            coreA.TARGET_MODE
                        ],
                        _computeMountainPointsMethod
                    ).req() as Array<Array<Number> >;

                PanoramaMountains.render(dc, mountainPoints, h);

                if (mode == 0) {
                    PanoramaSunEvents.render(
                        dc,
                        paths,
                        heading,
                        w,
                        h,
                        iconFont
                    );
                } else {
                    PanoramaMoonEvents.render(
                        dc,
                        paths,
                        heading,
                        w,
                        h,
                        iconFont
                    );
                }

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
