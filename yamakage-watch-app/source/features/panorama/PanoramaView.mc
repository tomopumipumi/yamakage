import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Core.ArenaConfig;
import Core.ApiSchema;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.PanoramaUiArena;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Ui.PageIndicator;
import Shared.Core.Router;
import Shared.Icons;
import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaSunPath;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaSunEvents;
import Features.Panorama.Components.PanoramaLabels;

module Features {
    module Panorama {
        class PanoramaView extends WatchUi.View {
            private var _timer as Timer.Timer;
            private var _shadowCx as ArenaConfig.Context;

            function initialize() {
                View.initialize();
                _timer = new Timer.Timer();
                _shadowCx = ArenaConfig.useArena(
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

                var iconFontCx = ArenaConfig.useArena(
                    ArenaType.PANORAMA_UI,
                    PanoramaUiArena.DataType.ICON_FONT
                );
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
                            (w * 0.1).toNumber(),
                            (h * 0.1).toNumber(),
                            iconFonts
                        )
                    );
                }
            }

            function onShow() {
                _timer.start(method(:requestUpdate), 100, true);
            }

            function onHide() {
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
                var iconFont =
                    ArenaConfig.useArena(
                        ArenaType.PANORAMA_UI,
                        PanoramaUiArena.DataType.ICON_FONT
                    ).get() as Graphics.FontType;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                Components.PanoramaGrid.render(dc, w, h);

                var data = _shadowCx.get() as ApiSchema.ShadowDataPayload?;
                if (data == null) {
                    return;
                }

                var profiles =
                    data[Core.ApiSchema.DataIndex.AZIMUTH_PROFILES] as
                    ApiSchema.AzimuthProfilesArray;
                var step =
                    data[Core.ApiSchema.DataIndex.AZIMUTH_STEP] as Number;
                var sunPaths =
                    data[Core.ApiSchema.DataIndex.SUN_PATHS] as
                    ApiSchema.SunPathArray;
                var heading =
                    CompassSensor.getHeadingDegrees() == null
                        ? 0.0
                        : CompassSensor.getHeadingDegrees();

                PanoramaSunPath.render(dc, sunPaths, heading, w, h);

                PanoramaMountains.render(dc, profiles, step, heading, w, h);

                PanoramaSunEvents.render(dc, sunPaths, heading, w, h, iconFont);

                PanoramaLabels.render(dc, heading, w, h, cx);

                PageIndicator.render(
                    dc,
                    Router.TOTAL_PAGES,
                    Router.Page.PANORAMA,
                    w,
                    h
                );
            }
        }
    }
}
