import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Math;
import Shared.Core.Page;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;
import Shared.Logic.FontManager;
import Shared.Logic.PositionConfigure;
import Features.Loading.Components.LoadingSun;
import Features.Loading.Components.LoadingMoon;
import Features.Loading.Components.LoadingMountains;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.LoadingUiArena as loadA;

module Features {
    module Loading {
        class LoadingView extends WatchUi.View {
            function initialize() {
                View.initialize();
            }

            function onShow() as Void {
                MH.SharedTimer.subscribe(self, :onTimerTick);

                var mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();
                var targetDataKey =
                    mode == 0 ? coreA.SUN_SHADOW_DATA : coreA.MOON_SHADOW_DATA;

                MH.watch(self, :onStateChanged, [
                    targetDataKey,
                    coreA.LAST_ERROR
                ]);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :onTimerTick);
                MH.unwatch(self, :onStateChanged);
                MH.destroy(:loading_angle);
            }

            function onStateChanged(values as Array) as Void {
                var data = values[0];
                var err = values[1];

                var pageNum =
                    data != null
                        ? Page.PANORAMA
                        : err != null
                          ? Page.ERROR
                          : null;
                if (pageNum != null) {
                    MH.Router.switchTo(pageNum, WatchUi.SLIDE_LEFT);
                }
            }

            function onTimerTick() as Void {
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();

                if (animState.equals(ToggleValues.ON)) {
                    var angle = MH.useFloat(:loading_angle)
                        .init(0.0)
                        .req();
                    angle += 0.1;
                    if (angle > Math.PI * 2) {
                        angle -= Math.PI * 2;
                    }
                    MH.useFloat(:loading_angle).set(angle);
                    WatchUi.requestUpdate();
                }
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var fontCx = MH.useFont(loadA.MSG_FONT);
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

            function onUpdate(dc as Graphics.Dc) as Void {
                var w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                var cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                var mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();

                var font = MH.useFont(loadA.MSG_FONT)
                    .init(Graphics.FONT_XTINY)
                    .req();
                var msg = MH.useString(loadA.MSG_TEXT).init("Loading...").req();
                var angle = MH.useFloat(:loading_angle)
                    .init(0.0)
                    .req();

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var objY = (h * 0.35).toNumber();
                if (mode == 0) {
                    LoadingSun.render(dc, cx, objY, angle);
                } else {
                    LoadingMoon.render(dc, cx, objY, angle);
                }

                LoadingMountains.render(dc, w, h);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    cx,
                    (h * 0.7).toNumber(),
                    font,
                    msg,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
        }
    }
}
