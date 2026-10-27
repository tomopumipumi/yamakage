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
                const BG_UPDATE_INTERVAL = "bg_update_interval";
            }

            const FRAME_RATES = [
                { :label => "High", :val => 50 },
                { :label => "Med", :val => 100 },
                { :label => "Low", :val => 300 }
            ];

            const BG_UPDATE_OPTIONS = [
                { :label => "5 Min", :val => 5 * 60 },
                { :label => "10 Min", :val => 10 * 60 },
                { :label => "15 Min", :val => 15 * 60 },
                { :label => "30 Min", :val => 30 * 60 },
                { :label => "1 Hour", :val => 60 * 60 },
                { :label => "2 Hours", :val => 120 * 60 },
                { :label => "Off", :val => 0 }
            ];
        }
    }
}
