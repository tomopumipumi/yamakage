import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.FontManager;
import Shared.Logic.IconFontManager;
import Shared.Logic.PositionConfigure;
import Shared.Ui.PageIndicator;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Page;
import Shared.Icons;
import Shared.Ui.BackgroundAnimation;
import Shared.Logic.BackgroundAnimationLogic;

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
            // ==================================================
            // ID
            // ==================================================
            private const SKYPLOT_CLOUDS_KEY = :skyplot_clouds;
            private const SKYPLOT_STARS_KEY = :skyplot_stars;
            private const REQUEST_UPDATE_METHOD = :requestUpdate;

            // ==================================================
            // Cash
            // ==================================================
            private var _tickCount as Number = 0;
            private var _pulsePhase as Float = 0.0;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;
            private var _cy as Number = 0;
            private var _radius as Float = 0.0;
            private var _nFont as Graphics.FontType?;
            private var _iconFontResource as Graphics.FontType?;

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

            // ==================================================
            // Subscribe Method
            // ==================================================
            function requestUpdate() as Void {
                _tickCount++;
                if (_isAnimOn) {
                    _pulsePhase += 0.2;
                    if (_pulsePhase > Math.PI * 2) {
                        _pulsePhase -= Math.PI * 2;
                    }
                } else {
                    _pulsePhase = 0.0;
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

                if (_isAnimOn || _tickCount % 2 == 0) {
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
            }

            // ==================================================
            // Override Method
            // ==================================================
            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).req();
                _cx = MH.useNumber(coreA.CENTER_X).req();
                _cy = MH.useNumber(coreA.CENTER_Y).req();
                _radius = ((_w < _h ? _w : _h) / 2.0) * 0.75;

                var fontCx = MH.useFont(skyA.N_FONT);
                if (fontCx.get() == null) {
                    fontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "N",
                            (_w * 0.2).toNumber(),
                            (_h * 0.1).toNumber()
                        )
                    );
                }
                _nFont = fontCx.get() as Graphics.FontType;

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

                _cloudBuffer = MH.useArrayBuffer(SKYPLOT_CLOUDS_KEY, 20).req();
                _starBuffer = MH.useArrayBuffer(SKYPLOT_STARS_KEY, 60).req();
                _refreshData();

                MH.SharedTimer.subscribe(self, REQUEST_UPDATE_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, REQUEST_UPDATE_METHOD);
                MH.destroy(SKYPLOT_STARS_KEY);
                MH.destroy(SKYPLOT_CLOUDS_KEY);
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

                var heading = CompassSensor.getHeadingDegrees();

                SkyPlotGrid.render(dc, _cx, _cy, _radius, _nFont);
                AzimuthChart.render(dc, _profiles, _stepDeg, _cx, _cy, _radius);

                switch (_mode) {
                    case TargetMode.SUN:
                        SunPathChart.render(
                            dc,
                            _paths,
                            _cx,
                            _cy,
                            _radius,
                            _pulsePhase
                        );
                        SkyPlotSunEvents.render(
                            dc,
                            _paths,
                            _cx,
                            _cy,
                            _radius,
                            _iconFontResource
                        );
                        break;

                    case TargetMode.MOON:
                        MoonPathChart.render(
                            dc,
                            _paths,
                            _cx,
                            _cy,
                            _radius,
                            _fraction,
                            _phase,
                            _pulsePhase
                        );
                        SkyPlotMoonEvents.render(
                            dc,
                            _paths,
                            _cx,
                            _cy,
                            _radius,
                            _iconFontResource
                        );
                        break;
                }

                if (heading != null) {
                    HeadingMarker.render(
                        dc,
                        heading,
                        _profiles,
                        _stepDeg,
                        _cx,
                        _cy,
                        _radius
                    );
                }

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.SKYPLOT,
                    _w,
                    _h
                );
            }
        }
    }
}
