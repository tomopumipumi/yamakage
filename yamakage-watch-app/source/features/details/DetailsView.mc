import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core.ApiSchema;
import Core.ApiSchema.DataIndex;
import Shared.Core.Page;
import Hal.Sensor.CompassSensor;
import Systems.TimeSystem;
import Shared.Logic.FontManager;
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
            private var _shadowCx as mycx.PayloadContext;
            private var _requestUpdate as Lang.Method;

            function initialize() {
                View.initialize();
                _shadowCx = mycx.usePayload(coreA.CURRENT_SHADOW_DATA);
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
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                var cy = MH.useNumber(coreA.CENTER_Y).init(0).req();

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var rawData = _shadowCx.get() as ApiSchema.ShadowDataPayload?;
                if (rawData == null) {
                    var valueFont = MH.useFont(detailA.VALUE_FONT)
                        .init(Graphics.FONT_XTINY)
                        .req();

                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        cx,
                        cy,
                        valueFont,
                        "No Data",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                    return;
                }

                var sunsetUnix =
                    rawData[DataIndex.SUNSET_TIME] as Number or Long;
                var sunriseUnix =
                    rawData[DataIndex.SUNRISE_TIME] as Number or Long;
                var sunsetStr = TimeSystem.formatUnixTime(sunsetUnix);
                var sunriseStr = TimeSystem.formatUnixTime(sunriseUnix);

                var heading = CompassSensor.getHeadingDegrees();
                var elevStr = "--";
                if (heading != null) {
                    var stepDeg = rawData[DataIndex.AZIMUTH_STEP];
                    var profiles =
                        rawData[DataIndex.AZIMUTH_PROFILES] as
                        ApiSchema.AzimuthProfilesArray;
                    var index = (heading / stepDeg).toNumber();
                    if (index >= 0 && index < profiles.size()) {
                        var profile = profiles[index];
                        if (profile instanceof Array && profile.size() > 0) {
                            var el =
                                profile[0] instanceof Number ||
                                profile[0] instanceof Float
                                    ? profile[0].toFloat()
                                    : 0.0;
                            elevStr = el.format("%.1f") + "°";
                        }
                    }
                }

                var row1Y = (h * 0.25).toNumber();
                var row2Y = (h * 0.5).toNumber();
                var row3Y = (h * 0.75).toNumber();

                DetailsSeparators.render(dc, w, h);

                DetailsRow.render(
                    dc,
                    row1Y,
                    "SUNRISE",
                    sunriseStr,
                    Graphics.COLOR_YELLOW,
                    Icons.ICON_SUNRISE
                );
                DetailsRow.render(
                    dc,
                    row2Y,
                    "SUNSET",
                    sunsetStr,
                    Graphics.COLOR_PURPLE,
                    Icons.ICON_SUNSET
                );
                DetailsRow.render(
                    dc,
                    row3Y,
                    "HEADING",
                    elevStr,
                    Graphics.COLOR_GREEN,
                    Icons.ICON_ELEVATION_ANGLE
                );

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
