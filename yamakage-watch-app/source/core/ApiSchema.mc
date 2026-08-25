import Toybox.Lang;

module Core {
    module ApiSchema {
        module SunDataIndex {
            enum {
                SET_TIME = 0,
                RISE_TIME,
                CURRENT_ALTITUDE,
                AZIMUTH_STEP,
                PROFILES,
                PATHS
            }
        }

        module MoonDataIndex {
            enum {
                SET_TIME = 0,
                RISE_TIME,
                CURRENT_ALTITUDE,
                AZIMUTH_STEP,
                FRACTION,
                PHASE,
                PROFILES,
                PATHS
            }
        }

        module PathIndex {
            enum {
                TIME = 0,
                AZIMUTH,
                ALTITUDE
            }
        }

        typedef AzimuthProfilesArray as Array<Array<Number or Float> >;
        typedef PathPointTuple as Array<Number or Float>;
        typedef PathArray as Array<PathPointTuple>;

        typedef SunShadowPayload as Array<Object>;
        typedef MoonShadowPayload as Array<Object>;
    }
}
