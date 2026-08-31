import Toybox.Lang;
import Toybox.Graphics;
import Shared.Core.Consts.ToggleValues;
import Shared.Ui.Toggle;
import Shared.Ui.ValueSelector;

import Features.Settings.SettingsConfig;

module Features {
    module Settings {
        module SettingsRender {
            const _ROW_HEIGHT = 44;
            const _SPACING = 8;

            function render(dc as Graphics.Dc, props as Array) as Void {
                var cx = props[SettingsProps.CX] as Number;
                var rowWidth = props[SettingsProps.ROW_WIDTH] as Number;
                var startX = props[SettingsProps.START_X] as Number;
                var startY = props[SettingsProps.START_Y] as Number;
                var settingsLabelY =
                    props[SettingsProps.SETTINGS_LABEL_Y] as Number;

                var cursor = props[SettingsProps.CURSOR] as Number;
                var settings =
                    props[SettingsProps.SETTINGS_ARRAY] as Array<Dictionary>;
                var cachedValues =
                    props[SettingsProps.CACHED_VALUES] as Dictionary;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    cx,
                    settingsLabelY,
                    Graphics.FONT_XTINY,
                    "SETTINGS",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );

                for (var i = 0; i < settings.size(); i++) {
                    var setting = settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var id = setting[SettingsConfig.ID];

                    var isSelected = i == cursor;
                    var startYRow = startY + i * (_ROW_HEIGHT + _SPACING);

                    switch (type) {
                        case SettingsConfig.TYPE_TOGGLE:
                            var stateStr = cachedValues.get(id) as String;
                            var isOn = stateStr.equals(ToggleValues.ON);

                            Toggle.render(
                                dc,
                                startX,
                                startYRow,
                                rowWidth,
                                _ROW_HEIGHT,
                                setting[SettingsConfig.LABEL] as String,
                                isOn,
                                isSelected
                            );
                            break;

                        case SettingsConfig.TYPE_SELECTOR:
                            var idx = cachedValues.get(id) as Number;
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
                                _ROW_HEIGHT,
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
