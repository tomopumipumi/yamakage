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
            // ==================================================
            // ID
            // ==================================================
            private const SETTINGS_CURSOR_KEY = :settings_cursor;
            private const ON_CURSOR_CHANGED_METHOD = :onCursorChanged;

            // ==================================================
            // Cash
            // ==================================================
            private const ROW_HEIGHT = 44;
            private const SPACING = 8;

            private var _settings as Array<Dictionary>;
            private var _cachedValues as Dictionary;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;
            private var _rowWidth as Number = 0;
            private var _startX as Number = 0;
            private var _startY as Number = 0;
            private var _settingsLabelY as Number = 0;

            private var _cursor as Number = 0;

            // ==================================================
            // Subscribe Method
            // ==================================================
            function onCursorChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _cursor = vals[0] as Number;
                }
            }

            // ==================================================
            // Util Method
            // ==================================================
            public function refreshCache() as Void {
                for (var i = 0; i < _settings.size(); i++) {
                    var setting = _settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var id = setting[SettingsConfig.ID];

                    switch (type) {
                        case SettingsConfig.TYPE_TOGGLE:
                            var stateStr = MH.useStorageString(id)
                                .init(setting[SettingsConfig.DEFAULT])
                                .req();
                            _cachedValues.put(id, stateStr);
                            break;

                        case SettingsConfig.TYPE_SELECTOR:
                            var idx = MH.useStorageNumber(id)
                                .init(setting[SettingsConfig.DEFAULT])
                                .req();
                            _cachedValues.put(id, idx);
                            break;
                    }
                }
            }

            // ==================================================
            // Override Method
            // ==================================================
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

                _rowWidth = (_w * 0.85).toNumber();
                _startX = _cx - _rowWidth / 2;
                _startY = (_h * 0.28).toNumber();
                _settingsLabelY = (_h * 0.15).toNumber();
            }

            function onShow() as Void {
                _cursor = MH.useNumber(SETTINGS_CURSOR_KEY).init(0).req();
                refreshCache();
                MH.watch(self, ON_CURSOR_CHANGED_METHOD, [SETTINGS_CURSOR_KEY]);
            }

            function onHide() as Void {
                MH.unwatch(self, ON_CURSOR_CHANGED_METHOD);
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    _cx,
                    _settingsLabelY,
                    Graphics.FONT_XTINY,
                    "SETTINGS",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );

                for (var i = 0; i < _settings.size(); i++) {
                    var setting = _settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var id = setting[SettingsConfig.ID];

                    var isSelected = i == _cursor;
                    var startYRow = _startY + i * (ROW_HEIGHT + SPACING);

                    switch (type) {
                        case SettingsConfig.TYPE_TOGGLE:
                            var stateStr = _cachedValues.get(id) as String;
                            var isOn = stateStr.equals(ToggleValues.ON);

                            Toggle.render(
                                dc,
                                _startX,
                                startYRow,
                                _rowWidth,
                                ROW_HEIGHT,
                                setting[SettingsConfig.LABEL] as String,
                                isOn,
                                isSelected
                            );
                            break;

                        case SettingsConfig.TYPE_SELECTOR:
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
                                _startX,
                                startYRow,
                                _rowWidth,
                                ROW_HEIGHT,
                                setting[SettingsConfig.LABEL] as String,
                                valLabel,
                                isSelected
                            );
                            break;
                    }
                }
            }
        }
    }
}
