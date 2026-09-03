import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Shared.Logic.PositionConfigure;

using MonkeyHooks as MH;
using MonkeyHooks.Touchable as MHTouchable;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Settings {
        // ==================================================
        // Props
        // ==================================================
        module SettingsProps {
            enum {
                CX = 0, // Number
                ROW_WIDTH, // Number
                START_X, // Number
                START_Y, // Number
                SETTINGS_LABEL_Y, // Number
                CURSOR, // Number
                SETTINGS_ARRAY, // Array<Dictionary>
                CACHED_VALUES, // Dictionary
                DATA_SIZE = 8
            }
        }

        // ==================================================
        // View Container
        // ==================================================
        class SettingsView extends WatchUi.View {
            // ID
            private const SETTINGS_CURSOR_KEY = :settings_cursor;
            private const ON_CURSOR_CHANGED_METHOD = :onCursorChanged;

            private const _ROW_HEIGHT = 44;
            private const _SPACING = 8;

            private var _props as Array = new [SettingsProps.DATA_SIZE];

            function initialize() {
                View.initialize();

                _props[SettingsProps.SETTINGS_ARRAY] =
                    SettingsConfig.getSettings();
                _props[SettingsProps.CACHED_VALUES] = {};
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                var w = MH.useNumber(coreA.DISPLAY_WIDTH).req();
                var h = MH.useNumber(coreA.DISPLAY_HEIGHT).req();
                var cx = MH.useNumber(coreA.CENTER_X).req();

                _props[SettingsProps.CX] = cx;

                var rowWidth = (w * 0.85).toNumber();
                _props[SettingsProps.ROW_WIDTH] = rowWidth;
                _props[SettingsProps.START_X] = cx - rowWidth / 2;
                _props[SettingsProps.START_Y] = (h * 0.28).toNumber();
                _props[SettingsProps.SETTINGS_LABEL_Y] = (h * 0.15).toNumber();
            }

            function onShow() as Void {
                _props[SettingsProps.CURSOR] = MH.useNumber(SETTINGS_CURSOR_KEY)
                    .init(0)
                    .req();
                refreshCache();

                MH.watch(self, ON_CURSOR_CHANGED_METHOD, [SETTINGS_CURSOR_KEY]);

                if (System.getDeviceSettings().isTouchScreen) {
                    _touchableSetting();
                }
            }

            function onHide() as Void {
                MH.unwatch(self, ON_CURSOR_CHANGED_METHOD);

                if (System.getDeviceSettings().isTouchScreen) {
                    MHTouchable.clear();
                }
            }

            // ==================================================
            // Subscribe Methods
            // ==================================================
            function onCursorChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _props[SettingsProps.CURSOR] = vals[0] as Number;
                }
            }

            // ==================================================
            // Public Util Method
            // ==================================================
            public function refreshCache() as Void {
                var settings =
                    _props[SettingsProps.SETTINGS_ARRAY] as Array<Dictionary>;
                var cachedValues =
                    _props[SettingsProps.CACHED_VALUES] as Dictionary;

                for (var i = 0; i < settings.size(); i++) {
                    var setting = settings[i] as Dictionary;
                    var type = setting[SettingsConfig.TYPE];
                    var id = setting[SettingsConfig.ID];

                    switch (type) {
                        case SettingsConfig.TYPE_TOGGLE:
                            var stateStr = MH.useStorageString(id)
                                .init(setting[SettingsConfig.DEFAULT])
                                .req();
                            cachedValues.put(id, stateStr);
                            break;

                        case SettingsConfig.TYPE_SELECTOR:
                            var idx = MH.useStorageNumber(id)
                                .init(setting[SettingsConfig.DEFAULT])
                                .req();
                            cachedValues.put(id, idx);
                            break;
                    }
                }
            }

            // ==================================================
            // Private Methods
            // ==================================================
            private function _touchableSetting() as Void {
                MHTouchable.clear();

                var startX = _props[SettingsProps.START_X] as Number;
                var startY = _props[SettingsProps.START_Y] as Number;
                var rowWidth = _props[SettingsProps.ROW_WIDTH] as Number;
                var settings =
                    _props[SettingsProps.SETTINGS_ARRAY] as Array<Dictionary>;

                for (var i = 0; i < settings.size(); i++) {
                    var startYRow = startY + i * (_ROW_HEIGHT + _SPACING);

                    MHTouchable.registerRect(
                        i,
                        startX,
                        startYRow,
                        rowWidth,
                        _ROW_HEIGHT
                    );
                }
            }

            // ==================================================
            // Render
            // ==================================================
            function onUpdate(dc as Graphics.Dc) as Void {
                SettingsRender.render(dc, _props);
            }
        }
    }
}
