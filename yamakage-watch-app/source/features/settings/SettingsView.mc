import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Shared.Logic.PositionConfigure;
import Shared.Ui.Toggle;
import Shared.Ui.ValueSelector;
import Shared.Core.Consts.ToggleValues;
import Features.Settings.SettingsConfig;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Settings {
        class SettingsView extends WatchUi.View {
            private var _settings as Array<Dictionary>;
            private var _cachedValues as Dictionary;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;

            private var _cursor as Number = 0;

            function initialize() {
                View.initialize();
                _settings = SettingsConfig.getSettings();
                _cachedValues = {};
                refreshCache();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).req();
                _cx = MH.useNumber(coreA.CENTER_X).req();
            }

            function onShow() as Void {
                _cursor = MH.useNumber(:settings_cursor)
                    .init(0)
                    .req();

                refreshCache();

                MH.watch(self, :onCursorChanged, [:settings_cursor]);
            }

            function onHide() as Void {
                MH.unwatch(self, :onCursorChanged);
            }

            function onCursorChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _cursor = vals[0] as Number;
                }
            }

            public function refreshCache() as Void {
                for (var i = 0; i < _settings.size(); i++) {
                    var setting = _settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var id = setting[SettingsConfig.ID];

                    if (type == SettingsConfig.TYPE_TOGGLE) {
                        var stateStr = MH.useStorageString(id)
                            .init(setting[SettingsConfig.DEFAULT])
                            .req();
                        _cachedValues.put(id, stateStr);
                    } else if (type == SettingsConfig.TYPE_SELECTOR) {
                        var idx = MH.useStorageNumber(id)
                            .init(setting[SettingsConfig.DEFAULT])
                            .req();
                        _cachedValues.put(id, idx);
                    }
                }
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    _cx,
                    (_h * 0.15).toNumber(),
                    Graphics.FONT_XTINY,
                    "SETTINGS",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );

                var rowHeight = 44;
                var spacing = 8;
                var rowWidth = (_w * 0.85).toNumber();
                var startX = _cx - rowWidth / 2;
                var startY = (_h * 0.28).toNumber();

                for (var i = 0; i < _settings.size(); i++) {
                    var setting = _settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var id = setting[SettingsConfig.ID];

                    var isSelected = i == _cursor;
                    var startYRow = startY + i * (rowHeight + spacing);

                    if (type == SettingsConfig.TYPE_TOGGLE) {
                        var stateStr = _cachedValues.get(id) as String;
                        var isOn = stateStr.equals(ToggleValues.ON);

                        Toggle.render(
                            dc,
                            startX,
                            startYRow,
                            rowWidth,
                            rowHeight,
                            setting[SettingsConfig.LABEL] as String,
                            isOn,
                            isSelected
                        );
                    } else if (type == SettingsConfig.TYPE_SELECTOR) {
                        var idx = _cachedValues.get(id) as Number;
                        var options =
                            setting[SettingsConfig.OPTIONS] as
                            Array<Dictionary>;

                        if (idx < 0 || idx >= options.size()) {
                            idx = 0;
                        }

                        var valLabel = options[idx][:label] as String;
                        ValueSelector.render(
                            dc,
                            startX,
                            startYRow,
                            rowWidth,
                            rowHeight,
                            setting[SettingsConfig.LABEL] as String,
                            valLabel,
                            isSelected
                        );
                    }
                }
            }
        }
    }
}
