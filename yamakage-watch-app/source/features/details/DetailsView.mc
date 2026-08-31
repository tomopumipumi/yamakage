import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.FontManager;
import Shared.Core.Enums.TargetMode;
import Shared.Logic.PositionConfigure;
import Shared.Logic.IconFontManager;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.DetailsUiArena as detailA;
using Core.CustomContext as mycx;

module Features {
    module Details {
        // ==================================================
        // Props
        // ==================================================
        module DetailsProps {
            enum {
                W = 0,
                H,
                LAYOUT_CTX, // [w, labelFont, valueFont, iconFontResource]
                MODE,
                HAS_DATA,
                PROFILES,
                STEP_DEG,
                FRACTION,
                PHASE,
                SUNRISE_STR,
                SUNSET_STR,
                ILLUM_STR,
                LAST_HEADING,
                ELEV_STR,
                DATA_SIZE = 14
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class DetailsView extends WatchUi.View {
            // ID
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            private var _props as Array = new [DetailsProps.DATA_SIZE];

            private var _tickCount as Number = 0;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _props[DetailsProps.W] = MH.useNumber(coreA.DISPLAY_WIDTH)
                    .init(0)
                    .req();
                _props[DetailsProps.H] = MH.useNumber(coreA.DISPLAY_HEIGHT)
                    .init(0)
                    .req();

                var w = _props[DetailsProps.W] as Number;
                var h = _props[DetailsProps.H] as Number;

                var labelFontCx = MH.useNumber(detailA.LABEL_FONT);
                var valueFontCx = MH.useNumber(detailA.VALUE_FONT);

                if (labelFontCx.get() == null) {
                    labelFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "SUNRISE",
                            (w * 0.3).toNumber(),
                            (h * 0.08).toNumber()
                        )
                    );
                }
                if (valueFontCx.get() == null) {
                    valueFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "88:88 (00/00)",
                            (w * 0.5).toNumber(),
                            (h * 0.15).toNumber()
                        )
                    );
                }

                var iconFontIdxCx = MH.useNumber(coreA.ICON_FONT_INDEX);
                if (iconFontIdxCx.get() == null) {
                    iconFontIdxCx.set(
                        IconFontManager.calculateBestIconFontIndex(dc, w, h)
                    );
                }

                var labelFont = labelFontCx.req();
                var valueFont = valueFontCx.req();
                var iconFontResource = IconFontManager.loadIconFontResource(
                    iconFontIdxCx.req()
                );

                _props[DetailsProps.LAYOUT_CTX] = [
                    w,
                    labelFont,
                    valueFont,
                    iconFontResource
                ];
            }

            function onShow() as Void {
                _props[DetailsProps.MODE] = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();
                _refreshData();

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);

                _props[DetailsProps.LAYOUT_CTX] = null;
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onTimerTick() as Void {
                _tickCount++;
                if (_tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
            }

            // ==================================================
            // Private Method
            // ==================================================
            private function _refreshData() as Void {
                var mode = _props[DetailsProps.MODE] as Number;
                var data = null;
                _props[DetailsProps.HAS_DATA] = false;

                var setUnix = 0l;
                var riseUnix = 0l;

                switch (mode) {
                    case TargetMode.SUN:
                        data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                        if (data != null) {
                            setUnix =
                                data[SunDataIndex.SET_TIME] as Number or Long;
                            riseUnix =
                                data[SunDataIndex.RISE_TIME] as Number or Long;
                            _props[DetailsProps.STEP_DEG] =
                                data[SunDataIndex.AZIMUTH_STEP] as Number;
                            _props[DetailsProps.PROFILES] =
                                data[SunDataIndex.PROFILES] as
                                ApiSchema.AzimuthProfilesArray;
                            _props[DetailsProps.HAS_DATA] = true;
                        }
                        break;

                    case TargetMode.MOON:
                        data = mycx
                            .useMoonPayload(coreA.MOON_SHADOW_DATA)
                            .get();
                        if (data != null) {
                            setUnix =
                                data[MoonDataIndex.SET_TIME] as Number or Long;
                            riseUnix =
                                data[MoonDataIndex.RISE_TIME] as Number or Long;
                            _props[DetailsProps.STEP_DEG] =
                                data[MoonDataIndex.AZIMUTH_STEP] as Number;
                            _props[DetailsProps.PROFILES] =
                                data[MoonDataIndex.PROFILES] as
                                ApiSchema.AzimuthProfilesArray;
                            _props[DetailsProps.FRACTION] =
                                data[MoonDataIndex.FRACTION] as Float;
                            _props[DetailsProps.PHASE] =
                                data[MoonDataIndex.PHASE] as Float;
                            _props[DetailsProps.HAS_DATA] = true;
                        }
                        break;
                }

                if (_props[DetailsProps.HAS_DATA] as Boolean) {
                    var sunsetStr = DetailsLogic.formatTime(setUnix);
                    var sunriseStr = DetailsLogic.formatTime(riseUnix);
                    var sunsetDateStr = DetailsLogic.formatDate(setUnix);
                    var sunriseDateStr = DetailsLogic.formatDate(riseUnix);

                    if (!sunriseDateStr.equals("")) {
                        sunriseStr += " " + sunriseDateStr;
                    }
                    if (!sunsetDateStr.equals("")) {
                        sunsetStr += " " + sunsetDateStr;
                    }

                    _props[DetailsProps.SUNRISE_STR] = sunriseStr;
                    _props[DetailsProps.SUNSET_STR] = sunsetStr;

                    if (mode == TargetMode.MOON) {
                        _props[DetailsProps.ILLUM_STR] =
                            DetailsLogic.formatIllumination(
                                _props[DetailsProps.FRACTION] as Float
                            );
                    }
                }

                _props[DetailsProps.LAST_HEADING] = -999.0;
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                if (
                    _props[DetailsProps.HAS_DATA] != null &&
                    (_props[DetailsProps.HAS_DATA] as Boolean)
                ) {
                    var hData = CompassSensor.getHeadingDegrees();
                    var heading = hData != null ? hData : 0.0;
                    var lastHeading =
                        _props[DetailsProps.LAST_HEADING] as Float;

                    if (heading != lastHeading) {
                        _props[DetailsProps.ELEV_STR] =
                            DetailsLogic.getElevationString(
                                _props[DetailsProps.PROFILES] as
                                    ApiSchema.AzimuthProfilesArray,
                                _props[DetailsProps.STEP_DEG] as Number,
                                heading
                            );
                        _props[DetailsProps.LAST_HEADING] = heading;
                    }
                }

                DetailsRender.render(dc, _props);
            }
        }
    }
}
