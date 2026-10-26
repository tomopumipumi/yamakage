module Core {
    module ComplicationApiSchema {
        enum {
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
}
