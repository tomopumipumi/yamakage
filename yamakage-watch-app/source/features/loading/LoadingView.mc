import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Math;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.LoadingUiArena;
import Features.Loading.Components.LoadingSun;
import Features.Loading.Components.LoadingMountains;

module Features {
    module Loading {
        class LoadingView extends WatchUi.View {
            private var _message as String;
            private var _timer as Timer.Timer;
            private var _angle as Float = 0.0;

            function initialize(message as String) {
                View.initialize();
                _message = message;
                _timer = new Timer.Timer();
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

                var fontCx = ArenaConfig.useArena(
                    ArenaType.LOADING_UI,
                    LoadingUiArena.DataType.MSG_FONT
                );
                if (fontCx.get() == null) {
                    fontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "Calculating...",
                            (w * 0.9).toNumber(),
                            (h * 0.2).toNumber()
                        )
                    );
                }
            }

            function onShow() as Void {
                _timer.start(method(:onTimerTick), 100, true);
            }

            function onHide() as Void {
                _timer.stop();
            }

            function onTimerTick() as Void {
                _angle += 0.1;
                if (_angle > Math.PI * 2) {
                    _angle -= Math.PI * 2;
                }
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
                var font =
                    ArenaConfig.useArena(
                        ArenaType.LOADING_UI,
                        LoadingUiArena.DataType.MSG_FONT
                    ).get() as Graphics.FontType;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var sunY = (h * 0.35).toNumber();
                LoadingSun.render(dc, cx, sunY, _angle);

                LoadingMountains.render(dc, w, h);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    cx,
                    (h * 0.7).toNumber(),
                    font,
                    _message,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
        }
    }
}
