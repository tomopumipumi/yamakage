import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Shared.Logic.FontManager;
import Shared.Core.Page;
import Shared.Core.Enums.TargetMode;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
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
            private var _tickCount as Number = 0;

            function initialize() {
                View.initialize();
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(self, :requestUpdate);
            }
            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :requestUpdate);
            }
            function requestUpdate() as Void {
                _tickCount++;
                if (_tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();

                var labelFontCx = MH.useFont(detailA.LABEL_FONT);
                var valueFontCx = MH.useFont(detailA.VALUE_FONT);
                var iconFontCx = MH.useFont(detailA.ICON_FONT);

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
                            (w * 0.15).toNumber(),
                            (h * 0.15).toNumber(),
                            iconFonts
                        )
                    );
                }
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                var data = null;
                var setUnix = 0l;
                var riseUnix = 0l;
                var stepDeg = 0;
                var profiles = null;
                var fraction = 0.0;
                var phase = 0.0;

                if (mode == TargetMode.SUN) {
                    data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                    if (data != null) {
                        setUnix = data[SunDataIndex.SET_TIME] as Number or Long;
                        riseUnix =
                            data[SunDataIndex.RISE_TIME] as Number or Long;
                        stepDeg = data[SunDataIndex.AZIMUTH_STEP] as Number;
                        profiles =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                    }
                } else {
                    data = mycx.useMoonPayload(coreA.MOON_SHADOW_DATA).get();
                    if (data != null) {
                        setUnix =
                            data[MoonDataIndex.SET_TIME] as Number or Long;
                        riseUnix =
                            data[MoonDataIndex.RISE_TIME] as Number or Long;
                        stepDeg = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        profiles =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        fraction = data[MoonDataIndex.FRACTION] as Float;
                        phase = data[MoonDataIndex.PHASE] as Float;
                    }
                }

                if (data == null) {
                    return;
                }

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

                var heading = CompassSensor.getHeadingDegrees();
                var elevStr = DetailsLogic.getElevationString(
                    profiles,
                    stepDeg,
                    heading
                );

                var riseLabel =
                    mode == TargetMode.MOON ? "MOONRISE" : "SUNRISE";
                var setLabel = mode == TargetMode.MOON ? "MOONSET" : "SUNSET";
                var riseColor =
                    mode == TargetMode.MOON
                        ? Graphics.COLOR_WHITE
                        : Graphics.COLOR_YELLOW;
                var setColor =
                    mode == TargetMode.MOON
                        ? Graphics.COLOR_LT_GRAY
                        : Graphics.COLOR_PURPLE;
                var riseIcon =
                    mode == TargetMode.MOON
                        ? Icons.ICON_MOONRISE
                        : Icons.ICON_SUNRISE;
                var setIcon =
                    mode == TargetMode.MOON
                        ? Icons.ICON_MOONSET
                        : Icons.ICON_SUNSET;

                var numRows = mode == TargetMode.MOON ? 4 : 3;
                DetailsSeparators.render(dc, w, h, numRows);

                if (mode == TargetMode.MOON) {
                    var illumStr = DetailsLogic.formatIllumination(fraction);
                    DetailsRow.render(
                        dc,
                        (h * 0.2).toNumber(),
                        riseLabel,
                        sunriseStr,
                        riseColor,
                        riseIcon
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.4).toNumber(),
                        setLabel,
                        sunsetStr,
                        setColor,
                        setIcon
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.6).toNumber(),
                        "HEADING",
                        elevStr,
                        Graphics.COLOR_GREEN,
                        Icons.ICON_ELEVATION_ANGLE
                    );

                    DetailsMoonRow.render(
                        dc,
                        (h * 0.8).toNumber(),
                        "ILLUM",
                        illumStr,
                        Graphics.COLOR_BLUE,
                        fraction,
                        phase
                    );
                } else {
                    DetailsRow.render(
                        dc,
                        (h * 0.25).toNumber(),
                        riseLabel,
                        sunriseStr,
                        riseColor,
                        riseIcon
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.5).toNumber(),
                        setLabel,
                        sunsetStr,
                        setColor,
                        setIcon
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.75).toNumber(),
                        "HEADING",
                        elevStr,
                        Graphics.COLOR_GREEN,
                        Icons.ICON_ELEVATION_ANGLE
                    );
                }

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.DETAILS,
                    w,
                    h
                );
            }
        }
    }
}
