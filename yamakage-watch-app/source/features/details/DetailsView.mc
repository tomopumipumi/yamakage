import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.DetailsUiArena;
import Core.ApiSchema;
import Core.ApiSchema.DataIndex;
import Hal.Sensor.CompassSensor;
import Systems.TimeSystem;
import Shared.Core.Router;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Shared.Ui.PageIndicator;
import Shared.Icons;
import Features.Details.Components.DetailsRow;
import Features.Details.Components.DetailsSeparators;

module Features {
    module Details {
        class DetailsView extends WatchUi.View {
            private var _timer as Timer.Timer;
            private var _shadowCtx as Core.ArenaConfig.Context;

            function initialize() {
                View.initialize();
                _timer = new Timer.Timer();
                _shadowCtx = ArenaConfig.useArena(
                    ArenaType.CORE,
                    CoreArena.DataType.CURRENT_SHADOW_DATA
                );
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
                var w =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_WIDTH
                    ).get() as Number;
                var h =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_HEIGHT
                    ).get() as Number;

                var labelFontCx = ArenaConfig.useArena(
                    ArenaType.DETAILS_UI,
                    DetailsUiArena.DataType.LABEL_FONT
                );
                var valueFontCx = ArenaConfig.useArena(
                    ArenaType.DETAILS_UI,
                    DetailsUiArena.DataType.VALUE_FONT
                );
                var iconFontCx = ArenaConfig.useArena(
                    ArenaType.DETAILS_UI,
                    DetailsUiArena.DataType.ICON_FONT
                );

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

            function onShow() as Void {
                _timer.start(method(:requestUpdate), 500, true);
            }
            function onHide() as Void {
                _timer.stop();
            }
            function requestUpdate() as Void {
                WatchUi.requestUpdate();
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                var w =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_WIDTH
                    ).get() as Number;
                var h =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.DISPLAY_HEIGHT
                    ).get() as Number;
                var cx =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_X
                    ).get() as Number;
                var cy =
                    ArenaConfig.useArena(
                        ArenaType.CORE,
                        CoreArena.DataType.CENTER_Y
                    ).get() as Number;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var rawData = _shadowCtx.get() as ApiSchema.ShadowDataPayload?;
                if (rawData == null) {
                    var valueFont =
                        ArenaConfig.useArena(
                            ArenaType.DETAILS_UI,
                            DetailsUiArena.DataType.VALUE_FONT
                        ).get() as Graphics.FontType;

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
                        elevStr =
                            profiles[index].toFloat().format("%.1f") + "°";
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
                    Router.TOTAL_PAGES,
                    Router.Page.DETAILS,
                    w,
                    h
                );
            }
        }
    }
}
