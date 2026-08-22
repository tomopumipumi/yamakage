import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Shared.Logic.FontManager;
import Shared.Core.Page;
import Hal.Sensor.CompassSensor;
import Systems.TimeSystem;
import Shared.Logic.PositionConfigure;
import Shared.Ui.PageIndicator;
import Shared.Icons;
import Features.Details.Components.DetailsRow;
import Features.Details.Components.DetailsSeparators;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.DetailsUiArena as detailA;
using Core.CustomContext as mycx;

module Features {
    module Details {
        class DetailsView extends WatchUi.View {
            private var _tickCount as Number = 0;
            private var _requestUpdate as Lang.Method;

            function initialize() {
                View.initialize();
                _requestUpdate = method(:requestUpdate);
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(_requestUpdate);
            }
            function onHide() as Void {
                MH.SharedTimer.unsubscribe(_requestUpdate);
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
                            "88:88",
                            (w * 0.4).toNumber(),
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

                var mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();

                var data = null;
                var setUnix = 0l;
                var riseUnix = 0l;
                var stepDeg = 0;
                var profiles = null;

                var illumStr = "--";

                if (mode == 0) {
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

                        var fraction = data[MoonDataIndex.FRACTION] as Float;
                        illumStr = (fraction * 100.0).format("%.1f") + "%";
                    }
                }

                if (data == null) {
                    return;
                }

                var sunsetStr = TimeSystem.formatUnixTime(setUnix);
                var sunriseStr = TimeSystem.formatUnixTime(riseUnix);

                var riseLabel = mode == 1 ? "MOONRISE" : "SUNRISE";
                var setLabel = mode == 1 ? "MOONSET" : "SUNSET";
                var riseColor =
                    mode == 1 ? Graphics.COLOR_WHITE : Graphics.COLOR_YELLOW;
                var setColor =
                    mode == 1 ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_PURPLE;

                var heading = CompassSensor.getHeadingDegrees();
                var elevStr = "--";
                if (heading != null) {
                    var index = (heading / stepDeg).toNumber();
                    if (
                        index >= 0 &&
                        index < profiles.size() &&
                        profiles[index].size() > 0
                    ) {
                        var el =
                            profiles[index][0] instanceof Number ||
                            profiles[index][0] instanceof Float
                                ? profiles[index][0].toFloat()
                                : 0.0;
                        elevStr = el.format("%.1f") + "°";
                    }
                }

                var numRows = mode == 1 ? 4 : 3;
                DetailsSeparators.render(dc, w, h, numRows);

                if (mode == 1) {
                    DetailsRow.render(
                        dc,
                        (h * 0.2).toNumber(),
                        riseLabel,
                        sunriseStr,
                        riseColor,
                        Icons.ICON_SUNRISE
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.4).toNumber(),
                        setLabel,
                        sunsetStr,
                        setColor,
                        Icons.ICON_SUNSET
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.6).toNumber(),
                        "HEADING",
                        elevStr,
                        Graphics.COLOR_GREEN,
                        Icons.ICON_ELEVATION_ANGLE
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.8).toNumber(),
                        "ILLUM",
                        illumStr,
                        Graphics.COLOR_BLUE,
                        Icons.ICON_MOON
                    );
                } else {
                    DetailsRow.render(
                        dc,
                        (h * 0.25).toNumber(),
                        riseLabel,
                        sunriseStr,
                        riseColor,
                        Icons.ICON_SUNRISE
                    );
                    DetailsRow.render(
                        dc,
                        (h * 0.5).toNumber(),
                        setLabel,
                        sunsetStr,
                        setColor,
                        Icons.ICON_SUNSET
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
