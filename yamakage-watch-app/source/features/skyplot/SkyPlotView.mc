import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Logic.IconFontManager;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;
import Shared.Logic.BackgroundAnimationLogic;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.SkyPlotUiArena as skyA;
using Core.CustomContext as mycx;

module Features {
    module SkyPlot {
        // ==================================================
        // Props
        // ==================================================
        module SkyPlotProps {
            enum {
                W = 0, //Number
                H, //Number
                CX, //Number
                CY, //Number
                RADIUS, // Float
                N_FONT, // Graphics.FontType
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
                PULSE_PHASE, // Float
                HEADING, // Float?
                DATA_SIZE = 19
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class SkyPlotView extends WatchUi.View {
            // ID
            private const SKYPLOT_CLOUDS_KEY = :skyplot_clouds;
            private const SKYPLOT_STARS_KEY = :skyplot_stars;
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            private var _props as Array = new [SkyPlotProps.DATA_SIZE];

            private var _tickCount as Number = 0;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[SkyPlotProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[SkyPlotProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();
                _props[SkyPlotProps.CX] = MH.useNumber(coreA.CENTER_X)
                    .init(0)
                    .req();
                _props[SkyPlotProps.CY] = MH.useNumber(coreA.CENTER_Y)
                    .init(0)
                    .req();

                var w = _props[SkyPlotProps.W] as Number;
                var h = _props[SkyPlotProps.H] as Number;

                _props[SkyPlotProps.RADIUS] = ((w < h ? w : h) / 2.0) * 0.75;

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
                _props[SkyPlotProps.N_FONT] = fontCx.get() as Graphics.FontType;

                var iconFontIdxCx = MH.useNumber(coreA.ICON_FONT_INDEX);
                if (iconFontIdxCx.get() == null) {
                    iconFontIdxCx.set(
                        IconFontManager.calculateBestIconFontIndex(dc, w, h)
                    );
                }

                _props[SkyPlotProps.ICON_FONT] =
                    IconFontManager.loadIconFontResource(iconFontIdxCx.req());
            }

            function onShow() as Void {
                _props[SkyPlotProps.MODE] = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _props[SkyPlotProps.IS_ANIM_ON] = animState.equals(
                    ToggleValues.ON
                );

                _props[SkyPlotProps.CLOUD_BUFFER] = MH.useArrayBuffer(
                    SKYPLOT_CLOUDS_KEY,
                    20
                ).req();
                _props[SkyPlotProps.STAR_BUFFER] = MH.useArrayBuffer(
                    SKYPLOT_STARS_KEY,
                    60
                ).req();

                _props[SkyPlotProps.PULSE_PHASE] = 0.0;

                _refreshData();

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
                MH.destroy(SKYPLOT_STARS_KEY);
                MH.destroy(SKYPLOT_CLOUDS_KEY);

                _props[SkyPlotProps.ICON_FONT] = null;
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onTimerTick() as Void {
                _tickCount++;

                var isAnimOn = _props[SkyPlotProps.IS_ANIM_ON] as Boolean;
                var pulsePhase = _props[SkyPlotProps.PULSE_PHASE] as Float;

                if (isAnimOn) {
                    pulsePhase += 0.2;
                    if (pulsePhase > Math.PI * 2) {
                        pulsePhase -= Math.PI * 2;
                    }
                } else {
                    pulsePhase = 0.0;
                }
                _props[SkyPlotProps.PULSE_PHASE] = pulsePhase;

                var w = _props[SkyPlotProps.W] as Number;
                var h = _props[SkyPlotProps.H] as Number;
                var mode = _props[SkyPlotProps.MODE] as Number;

                if (w > 0 && h > 0) {
                    if (
                        mode == TargetMode.SUN &&
                        _props[SkyPlotProps.CLOUD_BUFFER] != null
                    ) {
                        BackgroundAnimationLogic.updateClouds(
                            _props[SkyPlotProps.CLOUD_BUFFER] as Array,
                            w,
                            h,
                            isAnimOn
                        );
                    } else if (
                        mode == TargetMode.MOON &&
                        _props[SkyPlotProps.STAR_BUFFER] != null
                    ) {
                        BackgroundAnimationLogic.updateStars(
                            _props[SkyPlotProps.STAR_BUFFER] as Array,
                            w,
                            h,
                            isAnimOn
                        );
                    }
                }

                if (isAnimOn || _tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Private Method
            // ==================================================
            private function _refreshData() as Void {
                var mode = _props[SkyPlotProps.MODE] as Number;
                var data = null;
                _props[SkyPlotProps.HAS_DATA] = false;

                switch (mode) {
                    case TargetMode.SUN:
                        data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                        if (data == null) {
                            break;
                        }
                        _props[SkyPlotProps.STEP_DEG] =
                            data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _props[SkyPlotProps.PROFILES] =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _props[SkyPlotProps.PATHS] =
                            data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                        _props[SkyPlotProps.HAS_DATA] = true;
                        break;

                    case TargetMode.MOON:
                        data = mycx
                            .useMoonPayload(coreA.MOON_SHADOW_DATA)
                            .get();
                        if (data == null) {
                            break;
                        }
                        _props[SkyPlotProps.STEP_DEG] =
                            data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _props[SkyPlotProps.FRACTION] =
                            data[MoonDataIndex.FRACTION] as Float;
                        _props[SkyPlotProps.PHASE] =
                            data[MoonDataIndex.PHASE] as Float;
                        _props[SkyPlotProps.PROFILES] =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _props[SkyPlotProps.PATHS] =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                        _props[SkyPlotProps.HAS_DATA] = true;
                        break;
                }
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                var hasData = _props[SkyPlotProps.HAS_DATA];
                if (hasData != null && (hasData as Boolean)) {
                    _props[SkyPlotProps.HEADING] =
                        CompassSensor.getHeadingDegrees();
                } else {
                    _props[SkyPlotProps.HEADING] = null;
                }

                SkyPlotRender.render(dc, _props);
            }
        }
    }
}
