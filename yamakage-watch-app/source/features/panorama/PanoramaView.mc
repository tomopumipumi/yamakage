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
using Core.AppArena.PanoramaUiArena as panoramaA;
using Core.CustomContext as mycx;

module Features {
    module Panorama {
        class PanoramaView extends WatchUi.View {
            private var _tickCount as Number = 0;
            private var _pulsePhase as Float = 0.0;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;
            private var _iconFont as Graphics.FontType?;

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

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                _cx = MH.useNumber(coreA.CENTER_X).init(0).req();

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
                            (_w * 0.1).toNumber(),
                            (_h * 0.1).toNumber(),
                            iconFonts
                        )
                    );
                }
                _iconFont = iconFontCx.get() as Graphics.FontType;
            }

            function onShow() as Void {
                _mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _isAnimOn = animState.equals(ToggleValues.ON);

                _cloudBuffer = MH.useArrayBuffer(:panorama_clouds, 20).req();
                _starBuffer = MH.useArrayBuffer(:panorama_stars, 60).req();

                refreshData();

                MH.watch(self, :onTargetModeChanged, [coreA.TARGET_MODE]);
                MH.watch(self, :onAnimConfigChanged, [SettingIds.ANIM_ENABLED]);
                MH.watch(self, :onSunDataChanged, [coreA.SUN_SHADOW_DATA]);
                MH.watch(self, :onMoonDataChanged, [coreA.MOON_SHADOW_DATA]);

                MH.SharedTimer.subscribe(self, :onTimerTick);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :onTimerTick);

                MH.unwatch(self, :onTargetModeChanged);
                MH.unwatch(self, :onAnimConfigChanged);
                MH.unwatch(self, :onSunDataChanged);
                MH.unwatch(self, :onMoonDataChanged);

                MH.destroy(:panorama_stars);
                MH.destroy(:panorama_clouds);
            }

            function onTargetModeChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _mode = vals[0] as Number;
                    refreshData();
                }
            }

            function onAnimConfigChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    var animState = vals[0] as String;
                    _isAnimOn = animState.equals(ToggleValues.ON);
                }
            }

            function onSunDataChanged(vals as Array) as Void {
                if (_mode == TargetMode.SUN) {
                    refreshData();
                }
            }

            function onMoonDataChanged(vals as Array) as Void {
                if (_mode == TargetMode.MOON) {
                    refreshData();
                }
            }

            private function refreshData() as Void {
                var data = null;
                _hasData = false;

                if (_mode == TargetMode.SUN) {
                    data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                    if (data != null) {
                        _stepDeg = data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _profiles =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _paths =
                            data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                        _hasData = true;
                    }
                } else {
                    data = mycx.useMoonPayload(coreA.MOON_SHADOW_DATA).get();
                    if (data != null) {
                        _stepDeg = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _fraction = data[MoonDataIndex.FRACTION] as Float;
                        _phase = data[MoonDataIndex.PHASE] as Float;
                        _profiles =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _paths =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                        _hasData = true;
                    }
                }

                _lastHeadingForMountain = -999.0;
            }

            private function refreshMountains() as Void {
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
                    if (_mode == TargetMode.SUN && _cloudBuffer != null) {
                        BackgroundAnimationLogic.updateClouds(
                            _cloudBuffer,
                            _w,
                            _h,
                            _isAnimOn
                        );
                    } else if (
                        _mode == TargetMode.MOON &&
                        _starBuffer != null
                    ) {
                        BackgroundAnimationLogic.updateStars(
                            _starBuffer,
                            _w,
                            _h,
                            _isAnimOn
                        );
                    }
                }

                if (_isAnimOn || _tickCount == 0) {
                    WatchUi.requestUpdate();
                }
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

                if (_mode == TargetMode.SUN) {
                    PanoramaSunPath.render(
                        dc,
                        _paths,
                        _heading,
                        _w,
                        _h,
                        _pulsePhase
                    );
                } else {
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
                }

                if (_heading != _lastHeadingForMountain) {
                    refreshMountains();
                }
                PanoramaMountains.render(dc, _mountainPoints, _h);

                if (_mode == TargetMode.SUN) {
                    PanoramaSunEvents.render(
                        dc,
                        _paths,
                        _heading,
                        _w,
                        _h,
                        _iconFont
                    );
                } else {
                    PanoramaMoonEvents.render(
                        dc,
                        _paths,
                        _heading,
                        _w,
                        _h,
                        _iconFont
                    );
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
