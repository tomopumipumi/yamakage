import Toybox.Lang;
import Shared.Core.Consts;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;

module Features {
    module Settings {
        module SettingsConfig {
            enum {
                ID = 0,
                LABEL,
                DEFAULT,
                TYPE,
                OPTIONS
            }

            enum {
                TYPE_TOGGLE = 0,
                TYPE_SELECTOR
            }

            function getSettings() as Array<Dictionary> {
                return [
                    {
                        ID => SettingIds.ANIM_ENABLED,
                        LABEL => "Animations",
                        DEFAULT => ToggleValues.ON,
                        TYPE => TYPE_TOGGLE
                    },
                    {
                        ID => SettingIds.FRAME_RATE,
                        LABEL => "Anim Speed",
                        DEFAULT => "0",
                        TYPE => TYPE_SELECTOR,
                        OPTIONS => Consts.FRAME_RATES
                    }
                ];
            }
        }
    }
}
