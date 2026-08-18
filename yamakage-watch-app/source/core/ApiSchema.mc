import Toybox.Lang;

// {
//  "d": [
//     1718000000,  // Sunset Time
//     1718040000,  // Sunrise Time
//     50.5,        // Current Altitude
//     3,           // Azimuth Step (index * Azimuth Step = Azimuth)
//     [12.5, 13.1, 14.2, ...], // Elevation for each azimuth angle
//     [
//         [1718000000, 270.5, -0.8],   // sunPath [time, azimuth, altitude]
//         [1718000600, 271.2, -1.5]
//     ]
//  ]
// }

module Core {
    module ApiSchema {
        module DataIndex {
            enum {
                SUNSET_TIME,
                SUNRISE_TIME,
                CURRENT_ALTITUDE,
                AZIMUTH_STEP,
                AZIMUTH_PROFILES,
                SUN_PATHS
            }
        }

        module SunPathIndex {
            enum {
                TIME,
                AZIMUTH,
                ALTITUDE
            }
        }

        typedef AzimuthProfilesArray as Array<Number or Float>;

        typedef SunPathPointTuple as Array<Number or Float>;
        typedef SunPathArray as Array<SunPathPointTuple>;

        typedef ShadowDataPayload as
            Array<Number or Float or AzimuthProfilesArray or SunPathArray>;
    }
}
