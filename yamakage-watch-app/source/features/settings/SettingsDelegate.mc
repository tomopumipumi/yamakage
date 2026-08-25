import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Page;
import Features.Settings.SettingsConfig;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Settings {
        class SettingsDelegate extends WatchUi.BehaviorDelegate {
            var _view as SettingsView;
            var _lastTapTime as Number = 0;

            function initialize(view as SettingsView) {
                _view = view;
                BehaviorDelegate.initialize();
            }

            function onBack() as Boolean {
                MH.Router.pop(WatchUi.SLIDE_DOWN);
                return true;
            }

            function onNextPage() as Boolean {
                var size = SettingsConfig.getSettings().size();
                var cursorCx = MH.useNumber(:settings_cursor);
                var cursor = cursorCx.init(0).req();

                if (cursor < size - 1) {
                    cursorCx.set(cursor + 1);
                } else {
                    cursorCx.set(0);
                    MH.useNumber(coreA.TARGET_MODE).set(TargetMode.SUN);
                    MH.Router.switchTo(Page.MAIN, WatchUi.SLIDE_UP);
                }
                return true;
            }

            function onPreviousPage() as Boolean {
                var cursorCx = MH.useNumber(:settings_cursor);
                var cursor = cursorCx.init(0).req();

                if (cursor > 0) {
                    cursorCx.set(cursor - 1);
                } else {
                    cursorCx.set(0);
                    MH.useNumber(coreA.TARGET_MODE).set(TargetMode.MOON);
                    MH.Router.switchTo(Page.MAIN, WatchUi.SLIDE_DOWN);
                }
                return true;
            }

            function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
                if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
                    var settings = SettingsConfig.getSettings();
                    var cursor = MH.useNumber(:settings_cursor)
                        .init(0)
                        .req();
                    if (cursor >= 0 && cursor < settings.size()) {
                        toggleSetting(cursor);
                    }
                    return true;
                }
                return false;
            }

            function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
                _lastTapTime = System.getTimer();

                if (!System.getDeviceSettings().isTouchScreen) {
                    return false;
                }

                var y = clickEvent.getCoordinates()[1];
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).req();

                var startY = (h * 0.28).toNumber();
                var rowHeight = 44;
                var spacing = 8;
                var settings = SettingsConfig.getSettings();

                var hitIndex = (
                    (y - startY + spacing / 2.0) /
                    (rowHeight + spacing)
                ).toNumber();

                if (hitIndex >= 0 && hitIndex < settings.size()) {
                    MH.useNumber(:settings_cursor).set(hitIndex);
                    toggleSetting(hitIndex);
                }

                return true;
            }

            private function toggleSetting(settingIndex as Number) as Void {
                var setting = SettingsConfig.getSettings()[settingIndex];
                var id = setting[SettingsConfig.ID] as String;
                var type = setting[SettingsConfig.TYPE];

                if (type == null || type == SettingsConfig.TYPE_TOGGLE) {
                    var storageCx = MH.useStorageString(id);
                    var current = storageCx
                        .init(setting[SettingsConfig.DEFAULT])
                        .req();
                    storageCx.set(
                        current.equals(ToggleValues.ON)
                            ? ToggleValues.OFF
                            : ToggleValues.ON
                    );
                } else if (type == SettingsConfig.TYPE_SELECTOR) {
                    var storageCx = MH.useStorageNumber(id);
                    var currentIdx = storageCx
                        .init(setting[SettingsConfig.DEFAULT])
                        .req();

                    var options =
                        setting[SettingsConfig.OPTIONS] as Array<Dictionary>;
                    var nextIdx = (currentIdx + 1) % options.size();
                    storageCx.set(nextIdx);

                    if (id.equals(SettingIds.FRAME_RATE)) {
                        MH.SharedTimer.setInterval(
                            options[nextIdx][:val] as Number
                        );
                    }
                }

                _view.refreshCache();
                WatchUi.requestUpdate();
            }
        }
    }
}
