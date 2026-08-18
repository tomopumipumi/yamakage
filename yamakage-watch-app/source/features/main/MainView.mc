import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Shared.Ui.Button;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.MainUiArena;

module Features {
    module Main {
        class MainView extends WatchUi.View {
            function initialize() {
                View.initialize();
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

                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(
                    (w * 0.65).toNumber(),
                    (h * 0.5).toNumber(),
                    (w * 0.15).toNumber()
                );

                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillPolygon([
                    [0, h],
                    [(w * 0.1).toNumber(), (h * 0.55).toNumber()],
                    [(w * 0.4).toNumber(), (h * 0.7).toNumber()],
                    [(w * 0.8).toNumber(), (h * 0.45).toNumber()],
                    [w, (h * 0.6).toNumber()],
                    [w, h]
                ]);

                dc.setColor(
                    Graphics.COLOR_DK_GREEN,
                    Graphics.COLOR_TRANSPARENT
                );
                dc.fillPolygon([
                    [0, h],
                    [(w * 0.25).toNumber(), (h * 0.65).toNumber()],
                    [(w * 0.5).toNumber(), (h * 0.8).toNumber()],
                    [(w * 0.9).toNumber(), (h * 0.6).toNumber()],
                    [w, (h * 0.75).toNumber()],
                    [w, h]
                ]);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    cx,
                    (h * 0.25).toNumber(),
                    titleFont,
                    "YAMAKAGE",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );

                var isTouch = System.getDeviceSettings().isTouchScreen;

                if (isTouch) {
                    Button.render(
                        dc,
                        "START",
                        cx,
                        (h * 0.8).toNumber(),
                        btnWidth,
                        btnHeight,
                        btnFont,
                        Graphics.COLOR_DK_BLUE,
                        Graphics.COLOR_WHITE
                    );
                } else {
                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        cx,
                        (h * 0.8).toNumber(),
                        Graphics.FONT_SMALL,
                        "Press START",
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
