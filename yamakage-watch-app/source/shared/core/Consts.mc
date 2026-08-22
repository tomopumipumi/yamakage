module Shared {
    module Core {
        module Consts {
            const APP_TITLE = "YAMAKAGE";
            const SESSION_ID_KEY = "session_id";

            module ToggleValues {
                const ON = "on";
                const OFF = "off";
            }

            module SettingIds {
                const ANIM_ENABLED = "anim_enabled";
                const FRAME_RATE = "frame_rate";
            }

            const FRAME_RATES = [
                { :label => "High", :val => 50 },
                { :label => "Med", :val => 100 },
                { :label => "Low", :val => 300 }
            ];
        }
    }
}
