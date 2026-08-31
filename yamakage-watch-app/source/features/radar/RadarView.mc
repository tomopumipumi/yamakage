import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Core.ApiSchema;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.RadarUiArena as radarA;
using Core.CustomContext as mycx;

module Features {
    module Radar {
        // ==================================================
        // Props
        // ==================================================
        module RadarProps {
            enum {
                W = 0, // Number
                H, // Number
                CX, // Number
                CY, // Number
                RADIUS, // Float
                N_FONT, // Graphics.FontType
                IS_ANIM_ON, // Boolean
                MODE, // Number
                HAS_DATA, // Boolean
                STEP_DEG, // Number
                PROFILES, // ApiSchema.AzimuthProfilesArray
                PATHS, // ApiSchema.PathArray
                FRACTION, // Float
                PHASE, // Float
                SWEEP_ANGLE, // Float
                HEADING, // Float?
                DATA_SIZE = 16
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class RadarView extends WatchUi.View {
            // ID
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            private var _props as Array = new [RadarProps.DATA_SIZE];

            private var _tickCount as Number = 0;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[RadarProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[RadarProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();
                _props[RadarProps.CX] = MH.useNumber(coreA.CENTER_X)
                    .init(0)
                    .req();
                _props[RadarProps.CY] = MH.useNumber(coreA.CENTER_Y)
                    .init(0)
                    .req();

                var w = _props[RadarProps.W] as Number;
                var h = _props[RadarProps.H] as Number;

                _props[RadarProps.RADIUS] = ((w < h ? w : h) / 2.0) * 0.75;

                var fontCx = MH.useFont(radarA.N_FONT);
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
                _props[RadarProps.N_FONT] = fontCx.get() as Graphics.FontType;
            }

            function onShow() as Void {
                _props[RadarProps.MODE] = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _props[RadarProps.IS_ANIM_ON] = animState.equals(
                    ToggleValues.ON
                );

                _props[RadarProps.SWEEP_ANGLE] = 0.0;

                _refreshData();

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onTimerTick() as Void {
                _tickCount++;

                var isAnimOn = _props[RadarProps.IS_ANIM_ON] as Boolean;

                if (isAnimOn) {
                    var sweepAngle = _props[RadarProps.SWEEP_ANGLE] as Float;
                    sweepAngle += 0.05;
                    if (sweepAngle > Math.PI * 2) {
                        sweepAngle -= Math.PI * 2;
                    }
                    _props[RadarProps.SWEEP_ANGLE] = sweepAngle;
                } else {
                    _props[RadarProps.SWEEP_ANGLE] = 0.0;
                }

                if (isAnimOn || _tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Private Method
            // ==================================================
            private function _refreshData() as Void {
                var mode = _props[RadarProps.MODE] as Number;
                var data = null;
                _props[RadarProps.HAS_DATA] = false;

                switch (mode) {
                    case TargetMode.SUN:
                        data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                        if (data == null) {
                            break;
                        }
                        _props[RadarProps.STEP_DEG] =
                            data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _props[RadarProps.PROFILES] =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _props[RadarProps.PATHS] =
                            data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                        _props[RadarProps.HAS_DATA] = true;
                        break;

                    case TargetMode.MOON:
                        data = mycx
                            .useMoonPayload(coreA.MOON_SHADOW_DATA)
                            .get();
                        if (data == null) {
                            break;
                        }
                        _props[RadarProps.STEP_DEG] =
                            data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _props[RadarProps.FRACTION] =
                            data[MoonDataIndex.FRACTION] as Float;
                        _props[RadarProps.PHASE] =
                            data[MoonDataIndex.PHASE] as Float;
                        _props[RadarProps.PROFILES] =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _props[RadarProps.PATHS] =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                        _props[RadarProps.HAS_DATA] = true;
                        break;
                }
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                var hasData = _props[RadarProps.HAS_DATA];
                if (hasData != null && (hasData as Boolean)) {
                    _props[RadarProps.HEADING] =
                        CompassSensor.getHeadingDegrees();
                } else {
                    _props[RadarProps.HEADING] = null;
                }

                RadarRender.render(dc, _props);
            }
        }
    }
}
