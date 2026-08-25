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
            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;
            private var _font as Graphics.FontType?;

            private var _mode as Number = 0;
            private var _isAnimOn as Boolean = true;
            private var _msg as String = "Loading...";

            private var _angle as Float = 0.0;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                _cx = MH.useNumber(coreA.CENTER_X).init(0).req();

                var fontCx = MH.useFont(loadA.MSG_FONT);
                if (fontCx.get() == null) {
                    fontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "Calculating...",
                            (_w * 0.9).toNumber(),
                            (_h * 0.2).toNumber()
                        )
                    );
                }
                _font = fontCx.get() as Graphics.FontType;
            }

            function onShow() as Void {
                _mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _isAnimOn = animState.equals(ToggleValues.ON);
                _msg = MH.useString(loadA.MSG_TEXT).init("Loading...").req();

                var targetDataKey =
                    _mode == 0 ? coreA.SUN_SHADOW_DATA : coreA.MOON_SHADOW_DATA;

                MH.watch(self, :onStateChanged, [
                    targetDataKey,
                    coreA.LAST_ERROR
                ]);
                MH.watch(self, :onMsgTextChanged, [loadA.MSG_TEXT]);
                MH.watch(self, :onAnimConfigChanged, [SettingIds.ANIM_ENABLED]);
                MH.watch(self, :onTargetModeChanged, [coreA.TARGET_MODE]);

                MH.SharedTimer.subscribe(self, :onTimerTick);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :onTimerTick);
                MH.unwatch(self, :onStateChanged);
                MH.unwatch(self, :onMsgTextChanged);
                MH.unwatch(self, :onAnimConfigChanged);
                MH.unwatch(self, :onTargetModeChanged);
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

            function onMsgTextChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _msg = vals[0] as String;
                    WatchUi.requestUpdate();
                }
            }

            function onAnimConfigChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    var animState = vals[0] as String;
                    _isAnimOn = animState.equals(ToggleValues.ON);
                }
            }

            function onTargetModeChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _mode = vals[0] as Number;
                }
            }

            function onTimerTick() as Void {
                if (_isAnimOn) {
                    _angle += 0.1;
                    if (_angle > Math.PI * 2) {
                        _angle -= Math.PI * 2;
                    }
                    WatchUi.requestUpdate();
                }
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var objY = (_h * 0.35).toNumber();
                if (_mode == 0) {
                    LoadingSun.render(dc, _cx, objY, _angle);
                } else {
                    LoadingMoon.render(dc, _cx, objY, _angle);
                }

                LoadingMountains.render(dc, _w, _h);

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                if (_font != null) {
                    dc.drawText(
                        _cx,
                        (_h * 0.7).toNumber(),
                        _font,
                        _msg,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
