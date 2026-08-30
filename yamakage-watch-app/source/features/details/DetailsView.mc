import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.FontManager;
import Shared.Core.Page;
import Shared.Core.Enums.TargetMode;
import Shared.Logic.PositionConfigure;
import Shared.Logic.IconFontManager;
import Shared.Ui.PageIndicator;
import Shared.Icons;

import Features.Details.DetailsLogic;
import Features.Details.Components.DetailsRow;
import Features.Details.Components.DetailsMoonRow;
import Features.Details.Components.DetailsSeparators;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.DetailsUiArena as detailA;
using Core.CustomContext as mycx;

module Features {
    module Details {
        class DetailsView extends WatchUi.View {
            // ==================================================
            // ID
            // ==================================================
            private const ON_TIMER_TICK_METHOD = :onTimerTick;

            // ==================================================
            // Cash
            // ==================================================
            private var _tickCount as Number = 0;

            private var _w as Number = 0;
            private var _h as Number = 0;

            private var _mode as Number = TargetMode.SUN;

            private var _hasData as Boolean = false;
            private var _stepDeg as Number = 0;
            private var _profiles as ApiSchema.AzimuthProfilesArray?;
            private var _fraction as Float = 0.0;
            private var _phase as Float = 0.0;

            private var _sunriseStr as String = "";
            private var _sunsetStr as String = "";
            private var _illumStr as String = "";

            private var _lastHeading as Float = -999.0;
            private var _elevStr as String = "";

            private var _layoutCtx as Array = [];
            private var _iconFontResource as Graphics.FontType?;

            // ==================================================
            // Subscribe Method
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
                var data = null;
                _hasData = false;
                var setUnix = 0l;
                var riseUnix = 0l;

                if (_mode == TargetMode.SUN) {
                    data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                    if (data != null) {
                        setUnix = data[SunDataIndex.SET_TIME] as Number or Long;
                        riseUnix =
                            data[SunDataIndex.RISE_TIME] as Number or Long;
                        _stepDeg = data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _profiles =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _hasData = true;
                    }
                } else {
                    data = mycx.useMoonPayload(coreA.MOON_SHADOW_DATA).get();
                    if (data != null) {
                        setUnix =
                            data[MoonDataIndex.SET_TIME] as Number or Long;
                        riseUnix =
                            data[MoonDataIndex.RISE_TIME] as Number or Long;
                        _stepDeg = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _profiles =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _fraction = data[MoonDataIndex.FRACTION] as Float;
                        _phase = data[MoonDataIndex.PHASE] as Float;
                        _hasData = true;
                    }
                }

                if (_hasData) {
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

                    _sunriseStr = sunriseStr;
                    _sunsetStr = sunsetStr;

                    if (_mode == TargetMode.MOON) {
                        _illumStr = DetailsLogic.formatIllumination(_fraction);
                    }
                }

                _lastHeading = -999.0;
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

                var labelFontCx = MH.useFont(detailA.LABEL_FONT);
                var valueFontCx = MH.useFont(detailA.VALUE_FONT);

                if (labelFontCx.get() == null) {
                    labelFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "SUNRISE",
                            (_w * 0.3).toNumber(),
                            (_h * 0.08).toNumber()
                        )
                    );
                }
                if (valueFontCx.get() == null) {
                    valueFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "88:88 (00/00)",
                            (_w * 0.5).toNumber(),
                            (_h * 0.15).toNumber()
                        )
                    );
                }

                var iconFontIdxCx = MH.useNumber(coreA.ICON_FONT_INDEX);
                if (iconFontIdxCx.get() == null) {
                    iconFontIdxCx.set(
                        IconFontManager.calculateBestIconFontIndex(dc, _w, _h)
                    );
                }

                var labelFont = labelFontCx.req();
                var valueFont = valueFontCx.req();
                _iconFontResource = IconFontManager.loadIconFontResource(
                    iconFontIdxCx.req()
                );

                _layoutCtx = [_w, labelFont, valueFont, _iconFontResource];
            }

            function onShow() as Void {
                _mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();
                _refreshData();

                MH.SharedTimer.subscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, ON_TIMER_TICK_METHOD);
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                if (!_hasData) {
                    return;
                }

                var hData = CompassSensor.getHeadingDegrees();
                var heading = hData != null ? hData : 0.0;

                if (heading != _lastHeading) {
                    _elevStr = DetailsLogic.getElevationString(
                        _profiles,
                        _stepDeg,
                        heading
                    );
                    _lastHeading = heading;
                }

                var riseLabel =
                    _mode == TargetMode.MOON ? "MOONRISE" : "SUNRISE";
                var setLabel = _mode == TargetMode.MOON ? "MOONSET" : "SUNSET";
                var riseColor =
                    _mode == TargetMode.MOON
                        ? Graphics.COLOR_WHITE
                        : Graphics.COLOR_YELLOW;
                var setColor =
                    _mode == TargetMode.MOON
                        ? Graphics.COLOR_LT_GRAY
                        : Graphics.COLOR_PURPLE;
                var riseIcon =
                    _mode == TargetMode.MOON
                        ? Icons.ICON_MOONRISE
                        : Icons.ICON_SUNRISE;
                var setIcon =
                    _mode == TargetMode.MOON
                        ? Icons.ICON_MOONSET
                        : Icons.ICON_SUNSET;

                var numRows = _mode == TargetMode.MOON ? 4 : 3;
                DetailsSeparators.render(dc, _w, _h, numRows);

                switch (_mode) {
                    case TargetMode.SUN:
                        DetailsRow.render(
                            dc,
                            (_h * 0.25).toNumber(),
                            riseLabel,
                            _sunriseStr,
                            riseColor,
                            riseIcon,
                            _layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (_h * 0.5).toNumber(),
                            setLabel,
                            _sunsetStr,
                            setColor,
                            setIcon,
                            _layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (_h * 0.75).toNumber(),
                            "HEADING",
                            _elevStr,
                            Graphics.COLOR_GREEN,
                            Icons.ICON_ELEVATION_ANGLE,
                            _layoutCtx
                        );
                        break;

                    case TargetMode.MOON:
                        DetailsRow.render(
                            dc,
                            (_h * 0.2).toNumber(),
                            riseLabel,
                            _sunriseStr,
                            riseColor,
                            riseIcon,
                            _layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (_h * 0.4).toNumber(),
                            setLabel,
                            _sunsetStr,
                            setColor,
                            setIcon,
                            _layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (_h * 0.6).toNumber(),
                            "HEADING",
                            _elevStr,
                            Graphics.COLOR_GREEN,
                            Icons.ICON_ELEVATION_ANGLE,
                            _layoutCtx
                        );
                        DetailsMoonRow.render(
                            dc,
                            (_h * 0.8).toNumber(),
                            "ILLUM",
                            _illumStr,
                            Graphics.COLOR_BLUE,
                            _fraction,
                            _phase,
                            _layoutCtx
                        );
                        break;
                }

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.DETAILS,
                    _w,
                    _h
                );
            }
        }
    }
}
