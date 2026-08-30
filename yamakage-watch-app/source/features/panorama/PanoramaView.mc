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
import Shared.Logic.IconFontManager;
import Shared.Ui.PageIndicator;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Page;
import Shared.Icons;
import Shared.Ui.BackgroundAnimation;
import Shared.Logic.BackgroundAnimationLogic;

import Features.Panorama.PanoramaLogic;
import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaSunPath;
import Features.Panorama.Components.PanoramaMoonPath;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaSunEvents;
import Features.Panorama.Components.PanoramaMoonEvents;
import Features.Panorama.Components.PanoramaLabels;
import Features.Panorama.Components.PanoramaBackground;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.CustomContext as mycx;

module Features {
    module Panorama {
        class PanoramaView extends WatchUi.View {
            // ==================================================
            // ID
            // ==================================================
            private const PANORAMA_CLOUDS_KEY = :panorama_clouds;
            private const PANORAMA_STARS_KEY = :panorama_stars;
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            // ==================================================
            // Cash
            // ==================================================
            private var _tickCount as Number = 0;
            private var _pulsePhase as Float = 0.0;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;

            private var _isAnimOn as Boolean = true;
            private var _mode as Number = TargetMode.SUN;
            private var _cloudBuffer as Array?;
            private var _starBuffer as Array?;

            private var _hasData as Boolean = false;
            private var _stepDeg as Number = 0;
            private var _profiles as ApiSchema.AzimuthProfilesArray?;
            private var _paths as ApiSchema.PathArray?;
            private var _fraction as Float = 1.0;
            private var _phase as Float = 0.5;

            private var _heading as Float = 0.0;
            private var _lastHeadingForMountain as Float = -999.0;
            private var _mountainPoints as Array<Array<Number> > =
                [] as Array<Array<Number> >;

            private var _iconFontResource as Graphics.FontType?;

            // ==================================================
            // Subscribe Method
            // ==================================================
            function onTimerTick() as Void {
                if (_isAnimOn) {
                    _pulsePhase += 0.2;
                    if (_pulsePhase > Math.PI * 2) {
                        _pulsePhase -= Math.PI * 2;
                    }
                } else {
                    _pulsePhase = 0.0;
                }

                _tickCount = (_tickCount + 1) % 2;

                if (_tickCount == 0) {
                    var hData = CompassSensor.getHeadingDegrees();
                    _heading = hData != null ? hData : 0.0;
                }

                if (_w > 0 && _h > 0) {
                    switch (_mode) {
                        case TargetMode.SUN:
                            if (_cloudBuffer == null) {
                                break;
                            }
                            BackgroundAnimationLogic.updateClouds(
                                _cloudBuffer,
                                _w,
                                _h,
                                _isAnimOn
                            );
                            break;

                        case TargetMode.MOON:
                            if (_starBuffer == null) {
                                break;
                            }
                            BackgroundAnimationLogic.updateStars(
                                _starBuffer,
                                _w,
                                _h,
                                _isAnimOn
                            );
                            break;
                    }
                }

                if (_isAnimOn || _tickCount == 0) {
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Private Method
            // ==================================================
            private function _refreshData() as Void {
                var data = null;
                _hasData = false;

                switch (_mode) {
                    case TargetMode.SUN:
                        data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                        if (data == null) {
                            break;
                        }
                        _stepDeg = data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _profiles =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _paths =
                            data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                        _hasData = true;
                        break;

                    case TargetMode.MOON:
                        data = mycx
                            .useMoonPayload(coreA.MOON_SHADOW_DATA)
                            .get();
                        if (data == null) {
                            break;
                        }
                        _stepDeg = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _fraction = data[MoonDataIndex.FRACTION] as Float;
                        _phase = data[MoonDataIndex.PHASE] as Float;
                        _profiles =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _paths =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                        _hasData = true;
                        break;
                }

                _lastHeadingForMountain = -999.0;
            }

            private function _refreshMountains() as Void {
                if (!_hasData || _profiles == null) {
                    _mountainPoints = [] as Array<Array<Number> >;
                    return;
                }

                _mountainPoints =
                    PanoramaLogic.getPanoramaPoints(
                        _profiles,
                        _stepDeg,
                        _heading,
                        _w,
                        _h
                    ) as Array<Array<Number> >;

                _lastHeadingForMountain = _heading;
            }

            // ==================================================
            // Override Method
            // ==================================================
            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                _cx = MH.useNumber(coreA.CENTER_X).init(0).req();

                var iconFontIdxCx = MH.useNumber(coreA.ICON_FONT_INDEX);
                if (iconFontIdxCx.get() == null) {
                    iconFontIdxCx.set(
                        IconFontManager.calculateBestIconFontIndex(dc, _w, _h)
                    );
                }
                _iconFontResource = IconFontManager.loadIconFontResource(
                    iconFontIdxCx.req()
                );
            }

            function onShow() as Void {
                _mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _isAnimOn = animState.equals(ToggleValues.ON);

                _cloudBuffer = MH.useArrayBuffer(PANORAMA_CLOUDS_KEY, 20).req();
                _starBuffer = MH.useArrayBuffer(PANORAMA_STARS_KEY, 60).req();

                _refreshData();

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);

                MH.destroy(PANORAMA_STARS_KEY);
                MH.destroy(PANORAMA_CLOUDS_KEY);
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var activeBuffer =
                    _mode == TargetMode.SUN ? _cloudBuffer : _starBuffer;
                BackgroundAnimation.render(dc, _mode, activeBuffer);

                if (!_hasData) {
                    return;
                }

                PanoramaGrid.render(dc, _w, _h);

                switch (_mode) {
                    case TargetMode.SUN:
                        PanoramaSunPath.render(
                            dc,
                            _paths,
                            _heading,
                            _w,
                            _h,
                            _pulsePhase
                        );
                        break;

                    case TargetMode.MOON:
                        PanoramaMoonPath.render(
                            dc,
                            _paths,
                            _heading,
                            _w,
                            _h,
                            _fraction,
                            _phase,
                            _pulsePhase
                        );
                        break;
                }

                if (_heading != _lastHeadingForMountain) {
                    _refreshMountains();
                }
                PanoramaMountains.render(dc, _mountainPoints, _h);

                switch (_mode) {
                    case TargetMode.SUN:
                        PanoramaSunEvents.render(
                            dc,
                            _paths,
                            _heading,
                            _w,
                            _h,
                            _iconFontResource
                        );
                        break;

                    case TargetMode.MOON:
                        PanoramaMoonEvents.render(
                            dc,
                            _paths,
                            _heading,
                            _w,
                            _h,
                            _iconFontResource
                        );
                        break;
                }

                PanoramaLabels.render(dc, _heading, _w, _h, _cx);

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.PANORAMA,
                    _w,
                    _h
                );
            }
        }
    }
}
