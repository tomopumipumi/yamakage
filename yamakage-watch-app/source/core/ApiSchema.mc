import Toybox.Lang;

module Core {
    module ApiSchema {
        module SunDataIndex {
            enum {
                SET_TIME = 0,
                RISE_TIME = 1,
                CURRENT_ALTITUDE = 2,
                AZIMUTH_STEP = 3,
                PROFILES = 4,
                PATHS = 5
            }
        }

        module MoonDataIndex {
            enum {
                SET_TIME = 0,
                RISE_TIME = 1,
                CURRENT_ALTITUDE = 2,
                AZIMUTH_STEP = 3,
                FRACTION = 4,
                PHASE = 5,
                PROFILES = 6,
                PATHS = 7
            }
        }

        module PathIndex {
            enum {
                TIME = 0,
                AZIMUTH = 1,
                ALTITUDE = 2
            }
        }

        typedef AzimuthProfilesArray as Array<Array<Number or Float> >;
        typedef PathPointTuple as Array<Number or Float>;
        typedef PathArray as Array<PathPointTuple>;

        typedef SunShadowPayload as Array<Object>;
        typedef MoonShadowPayload as Array<Object>;
    }
}
