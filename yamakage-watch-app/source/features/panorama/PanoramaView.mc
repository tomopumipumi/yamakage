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
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;
import Shared.Icons;
import Shared.Logic.BackgroundAnimationLogic;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.CustomContext as mycx;

module Features {
    module Panorama {
        // ==================================================
        // Props
        // ==================================================
        module PanoramaProps {
            enum {
                W = 0, // Number
                H, // Number
                CX, // Number
                ICON_FONT, // Graphics.FontType
                IS_ANIM_ON, // Boolean
                MODE, // Number (TargetMode)
                CLOUD_BUFFER, // Array
                STAR_BUFFER, // Array
                HAS_DATA, // Boolean
                STEP_DEG, // Number
                PROFILES, // ApiSchema.AzimuthProfilesArray
                PATHS, // ApiSchema.PathArray
                FRACTION, // Float
                PHASE, // Float
                HEADING, // Float
                LAST_HEADING, // Float
                MOUNTAIN_POINTS, // Array<Array<Number>>
                PULSE_PHASE, // Float
                TICK_COUNT, // Number
                DATA_SIZE = 19
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class PanoramaView extends WatchUi.View {
            // ID
            private const PANORAMA_CLOUDS_KEY = :panorama_clouds;
            private const PANORAMA_STARS_KEY = :panorama_stars;
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            private var _props as Array = new [PanoramaProps.DATA_SIZE];

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[PanoramaProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[PanoramaProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();
                _props[PanoramaProps.CX] = MH.useNumber(coreA.CENTER_X)
                    .init(0)
                    .req();

                var w = _props[PanoramaProps.W] as Number;
                var h = _props[PanoramaProps.H] as Number;

                var iconFontIdxCx = MH.useNumber(coreA.ICON_FONT_INDEX);
                if (iconFontIdxCx.get() == null) {
                    iconFontIdxCx.set(
                        IconFontManager.calculateBestIconFontIndex(dc, w, h)
                    );
                }

                _props[PanoramaProps.ICON_FONT] =
                    IconFontManager.loadIconFontResource(iconFontIdxCx.req());
            }

            function onShow() as Void {
                _props[PanoramaProps.MODE] = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _props[PanoramaProps.IS_ANIM_ON] = animState.equals(
                    ToggleValues.ON
                );

                _props[PanoramaProps.CLOUD_BUFFER] = MH.useArrayBuffer(
                    PANORAMA_CLOUDS_KEY,
                    20
                ).req();
                _props[PanoramaProps.STAR_BUFFER] = MH.useArrayBuffer(
                    PANORAMA_STARS_KEY,
                    60
                ).req();

                _props[PanoramaProps.TICK_COUNT] = 0;
                _props[PanoramaProps.PULSE_PHASE] = 0.0;
                _props[PanoramaProps.HEADING] = 0.0;

                _refreshData();

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);

                MH.destroy(PANORAMA_STARS_KEY);
                MH.destroy(PANORAMA_CLOUDS_KEY);

                _props[PanoramaProps.ICON_FONT] = null;
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onTimerTick() as Void {
                var isAnimOn = _props[PanoramaProps.IS_ANIM_ON] as Boolean;
                var pulsePhase = _props[PanoramaProps.PULSE_PHASE] as Float;
                var tickCount = _props[PanoramaProps.TICK_COUNT] as Number;

                if (isAnimOn) {
                    pulsePhase += 0.2;
                    if (pulsePhase > Math.PI * 2) {
                        pulsePhase -= Math.PI * 2;
                    }
                } else {
                    pulsePhase = 0.0;
                }
                _props[PanoramaProps.PULSE_PHASE] = pulsePhase;

                tickCount = (tickCount + 1) % 2;
                _props[PanoramaProps.TICK_COUNT] = tickCount;

                if (tickCount == 0) {
                    var hData = CompassSensor.getHeadingDegrees();
                    _props[PanoramaProps.HEADING] = hData != null ? hData : 0.0;
                }

                var w = _props[PanoramaProps.W] as Number;
                var h = _props[PanoramaProps.H] as Number;
                var mode = _props[PanoramaProps.MODE] as Number;

                if (w > 0 && h > 0) {
                    if (
                        mode == TargetMode.SUN &&
                        _props[PanoramaProps.CLOUD_BUFFER] != null
                    ) {
                        BackgroundAnimationLogic.updateClouds(
                            _props[PanoramaProps.CLOUD_BUFFER] as Array,
                            w,
                            h,
                            isAnimOn
                        );
                    } else if (
                        mode == TargetMode.MOON &&
                        _props[PanoramaProps.STAR_BUFFER] != null
                    ) {
                        BackgroundAnimationLogic.updateStars(
                            _props[PanoramaProps.STAR_BUFFER] as Array,
                            w,
                            h,
                            isAnimOn
                        );
                    }
                }

                if (isAnimOn || tickCount == 0) {
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Private Method
            // ==================================================
            private function _refreshData() as Void {
                var mode = _props[PanoramaProps.MODE] as Number;
                var data = null;
                _props[PanoramaProps.HAS_DATA] = false;

                switch (mode) {
                    case TargetMode.SUN:
                        data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                        if (data == null) {
                            break;
                        }
                        _props[PanoramaProps.STEP_DEG] =
                            data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _props[PanoramaProps.PROFILES] =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _props[PanoramaProps.PATHS] =
                            data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                        _props[PanoramaProps.HAS_DATA] = true;
                        break;

                    case TargetMode.MOON:
                        data = mycx
                            .useMoonPayload(coreA.MOON_SHADOW_DATA)
                            .get();
                        if (data == null) {
                            break;
                        }
                        _props[PanoramaProps.STEP_DEG] =
                            data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _props[PanoramaProps.FRACTION] =
                            data[MoonDataIndex.FRACTION] as Float;
                        _props[PanoramaProps.PHASE] =
                            data[MoonDataIndex.PHASE] as Float;
                        _props[PanoramaProps.PROFILES] =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _props[PanoramaProps.PATHS] =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                        _props[PanoramaProps.HAS_DATA] = true;
                        break;
                }

                _props[PanoramaProps.LAST_HEADING] = -999.0;
            }

            private function _refreshMountains() as Void {
                var hasData = _props[PanoramaProps.HAS_DATA];
                var profiles = _props[PanoramaProps.PROFILES];

                if (
                    hasData == null ||
                    !(hasData as Boolean) ||
                    profiles == null
                ) {
                    _props[PanoramaProps.MOUNTAIN_POINTS] =
                        [] as Array<Array<Number> >;
                    return;
                }

                var heading = _props[PanoramaProps.HEADING] as Float;
                _props[PanoramaProps.MOUNTAIN_POINTS] =
                    PanoramaLogic.getPanoramaPoints(
                        profiles as ApiSchema.AzimuthProfilesArray,
                        _props[PanoramaProps.STEP_DEG] as Number,
                        heading,
                        _props[PanoramaProps.W] as Number,
                        _props[PanoramaProps.H] as Number
                    ) as Array<Array<Number> >;

                _props[PanoramaProps.LAST_HEADING] = heading;
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                var heading = _props[PanoramaProps.HEADING] as Float;
                var lastHeading = _props[PanoramaProps.LAST_HEADING] as Float;

                if (heading != lastHeading) {
                    _refreshMountains();
                }

                PanoramaRender.render(dc, _props);
            }
        }
    }
}
