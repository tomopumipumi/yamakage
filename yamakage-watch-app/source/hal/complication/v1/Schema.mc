module Hal {
    (:background)
    module Complication {
        (:background)
        module V1 {
            (:background)
            module Schema {
                enum {
                    VERSION = 0, // Number
                    TIMESTAMP, // Number (Unix timestamp)
                    STATUS, // Number
                    SUNRISE_TIME, // Number (Unix timestamp)
                    SUNSET_TIME, // Number (Unix timestamp)
                    MOONRISE_TIME, // Number (Unix timestamp)
                    MOONSET_TIME, // Number (Unix timestamp)
                    MOON_PHASE, // Number (0.0 to 1.0)
                    MOON_FRACTION, // Number (0.0 to 1.0)
                    ALTITUDE, // Number (meters)
                    DATA_SIZE
                }
            }

            (:background)
            module Status {
                enum {
                    SUCCESS = 0,
                    NO_GPS,
                    NETWORK_ERROR,
                    SERVER_ERROR,
                    UNKNOWN_ERROR
                }
            }
        }
    }
}
