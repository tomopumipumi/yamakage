import Toybox.Lang;
import Toybox.Test;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

module Features {
    module Settings {
        (:test)
        module TestFixture {
            function createDummyProps() as Array {
                var props = new [SettingsProps.DATA_SIZE];

                props[SettingsProps.CX] = 120;
                props[SettingsProps.ROW_WIDTH] = 204;
                props[SettingsProps.START_X] = 18;
                props[SettingsProps.START_Y] = 67;
                props[SettingsProps.SETTINGS_LABEL_Y] = 36;
                props[SettingsProps.CURSOR] = 0;
                props[SettingsProps.SETTINGS_ARRAY] =
                    SettingsConfig.getSettings();

                var cached = {};
                cached.put(SettingIds.ANIM_ENABLED, ToggleValues.ON);
                cached.put(SettingIds.FRAME_RATE, 0);
                props[SettingsProps.CACHED_VALUES] = cached;

                return props;
            }
        }
    }
}
