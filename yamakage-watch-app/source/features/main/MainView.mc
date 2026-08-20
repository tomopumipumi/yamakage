import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Position;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.MainUiArena;
import Features.Main.Components.MainBackground;
import Features.Main.Components.MainGpsStatus;
import Features.Main.Components.MainTitle;
import Features.Main.Components.MainStartAction;

module Features {
    module Main {
        class MainView extends WatchUi.View {
            private var _timer as Timer.Timer;

            function initialize() {
                View.initialize();
                _timer = new Timer.Timer();
            }

            function onShow() as Void {
                _timer.start(method(:requestUpdate), 1000, true);
                Position.enableLocationEvents(
                    Position.LOCATION_CONTINUOUS,
                    method(:onPositionUpdate)
                );
            }

            function onHide() as Void {
                _timer.stop();
                Position.enableLocationEvents(
                    Position.LOCATION_DISABLE,
                    method(:onPositionUpdate)
                );
            }

            function requestUpdate() as Void {
                WatchUi.requestUpdate();
            }

            function onPositionUpdate(info as Position.Info) as Void {}

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

                var titleFontCx = ArenaConfig.useArena(
                    ArenaType.MAIN_UI,
                    MainUiArena.DataType.TITLE_FONT
                );
                var btnFontCx = ArenaConfig.useArena(
                    ArenaType.MAIN_UI,
                    MainUiArena.DataType.BTN_FONT
                );
                var btnWidthCx = ArenaConfig.useArena(
                    ArenaType.MAIN_UI,
                    MainUiArena.DataType.BTN_WIDTH
                );
                var btnHeightCx = ArenaConfig.useArena(
                    ArenaType.MAIN_UI,
                    MainUiArena.DataType.BTN_HEIGHT
                );

                if (titleFontCx.get() == null) {
                    var btnWidth = (w * 0.5).toNumber();
                    var btnHeight = (h * 0.2).toNumber();

                    btnWidthCx.set(btnWidth);
                    btnHeightCx.set(btnHeight);

                    titleFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "YAMAKAGE",
                            (w * 0.8).toNumber(),
                            (h * 0.2).toNumber()
                        )
                    );
                    btnFontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "START",
                            btnWidth,
                            btnHeight
                        )
                    );
                }
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

                var titleFont =
                    ArenaConfig.useArena(
                        ArenaType.MAIN_UI,
                        MainUiArena.DataType.TITLE_FONT
                    ).get() as Graphics.FontType;
                var btnFont =
                    ArenaConfig.useArena(
                        ArenaType.MAIN_UI,
                        MainUiArena.DataType.BTN_FONT
                    ).get() as Graphics.FontType;
                var btnWidth =
                    ArenaConfig.useArena(
                        ArenaType.MAIN_UI,
                        MainUiArena.DataType.BTN_WIDTH
                    ).get() as Number;
                var btnHeight =
                    ArenaConfig.useArena(
                        ArenaType.MAIN_UI,
                        MainUiArena.DataType.BTN_HEIGHT
                    ).get() as Number;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                MainBackground.render(dc, w, h);

                var gpsY = (h * 0.1).toNumber();
                MainGpsStatus.render(dc, cx, gpsY);

                var titleY = (h * 0.25).toNumber();
                MainTitle.render(dc, cx, titleY, titleFont);

                var btnY = (h * 0.8).toNumber();
                MainStartAction.render(
                    dc,
                    cx,
                    btnY,
                    btnWidth,
                    btnHeight,
                    btnFont
                );
            }
        }
    }
}
