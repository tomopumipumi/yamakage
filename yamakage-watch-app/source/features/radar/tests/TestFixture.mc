import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.Math;

import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Radar {
        (:test)
        module TestFixture {
            function getDummyProfiles() as Array {
                // Simulates ApiSchema.AzimuthProfilesArray: [[elevation, distance], ...]
                // For radar, distance is important (Max dist is clamped to 30000.0m)
                return [
                    [10.0, 5000.0],
                    [25.0, 15000.0],
                    [30.0, 35000.0], // Exceeds max distance
                    [15.0, 20000.0],
                    [0.0, 500.0],
                    [-5.0, 0.0]
                ];
            }

            function getDummyPaths() as Array {
                // Simulates ApiSchema.PathArray: [[azimuth, altitude, time], ...]
                return [
                    [80.0, -10.0, 1600000000], // Below horizon
                    [90.0, 0.0, 1600001000], // Rise event
                    [180.0, 45.0, 1600005000], // Peak
                    [270.0, 0.0, 1600009000], // Set event
                    [280.0, -10.0, 1600010000] // Below horizon
                ];
            }

            function createDummyProps() as Array {
                var props = new [RadarProps.DATA_SIZE];
                props[RadarProps.W] = 240;
                props[RadarProps.H] = 240;
                props[RadarProps.CX] = 120;
                props[RadarProps.CY] = 120;
                props[RadarProps.RADIUS] = 90.0;
                props[RadarProps.N_FONT] = Graphics.FONT_TINY;
                props[RadarProps.IS_ANIM_ON] = true;
                props[RadarProps.MODE] = TargetMode.SUN;
                props[RadarProps.HAS_DATA] = true;
                props[RadarProps.STEP_DEG] = 15;
                props[RadarProps.PROFILES] = getDummyProfiles();
                props[RadarProps.PATHS] = getDummyPaths();
                props[RadarProps.FRACTION] = 0.5;
                props[RadarProps.PHASE] = 0.5;
                props[RadarProps.SWEEP_ANGLE] = Math.PI;
                props[RadarProps.HEADING] = 45.0;

                return props;
            }
        }
    }
}
