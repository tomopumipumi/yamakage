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
            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var w = MH.useNumber(coreA.DISPLAY_WIDTH).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).req();
                var cx = MH.useNumber(coreA.CENTER_X).req();

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    cx,
                    (h * 0.15).toNumber(),
                    Graphics.FONT_XTINY,
                    "SETTINGS",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );

                var settings = SettingsConfig.getSettings();
                var cursor = MH.useNumber(:settings_cursor)
                    .init(0)
                    .req();

                var rowHeight = 44;
                var spacing = 8;
                var rowWidth = (w * 0.85).toNumber();
                var startX = cx - rowWidth / 2;
                var startY = (h * 0.28).toNumber();

                for (var i = 0; i < settings.size(); i++) {
                    var setting = settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var isSelected = i == cursor;
                    var startYRow = startY + i * (rowHeight + spacing);

                    var stateStr = MH.useStorageString(
                        setting[SettingsConfig.ID]
                    )
                        .init(setting[SettingsConfig.DEFAULT])
                        .req();

                    if (type == SettingsConfig.TYPE_TOGGLE) {
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
                        var options =
                            setting[SettingsConfig.OPTIONS] as
                            Array<Dictionary>;
                        var idx = stateStr.toNumber();
                        if (idx == null || idx < 0 || idx >= options.size()) {
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
