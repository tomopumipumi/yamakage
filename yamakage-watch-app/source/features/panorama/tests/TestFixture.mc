import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Panorama {
        (:test)
        module TestFixture {
            function _createFilledArray(size as Number) as Array<Float> {
                var arr = new [size] as Array<Float>;
                for (var i = 0; i < size; i++) {
                    arr[i] = 0.0;
                }
                return arr;
            }

            function getDummyProfiles() as Array {
                // Simulates ApiSchema.AzimuthProfilesArray: [[elevation], ...]
                return [[10.0], [25.0], [30.0], [15.0], [0.0], [-5.0]];
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

            function getDummyMountainPoints() as Array {
                // Pre-calculated points for PanoramaMountains component
                return (
                    [
                        [0, 150],
                        [60, 100],
                        [120, 80],
                        [180, 130],
                        [240, 150]
                    ] as Array<Array<Number> >
                );
            }

            function createDummyProps() as Array {
                var props = new [PanoramaProps.DATA_SIZE];
                props[PanoramaProps.W] = 240;
                props[PanoramaProps.H] = 240;
                props[PanoramaProps.CX] = 120;
                props[PanoramaProps.ICON_FONT] = Graphics.FONT_TINY; // Using tiny as mock icon font
                props[PanoramaProps.IS_ANIM_ON] = true;
                props[PanoramaProps.MODE] = TargetMode.SUN;
                props[PanoramaProps.CLOUD_BUFFER] = _createFilledArray(20);
                props[PanoramaProps.STAR_BUFFER] = _createFilledArray(60);
                props[PanoramaProps.HAS_DATA] = true;
                props[PanoramaProps.STEP_DEG] = 15;
                props[PanoramaProps.PROFILES] = getDummyProfiles();
                props[PanoramaProps.PATHS] = getDummyPaths();
                props[PanoramaProps.FRACTION] = 0.5;
                props[PanoramaProps.PHASE] = 0.5;
                props[PanoramaProps.HEADING] = 180.0;
                props[PanoramaProps.LAST_HEADING] = -999.0;
                props[PanoramaProps.MOUNTAIN_POINTS] = getDummyMountainPoints();
                props[PanoramaProps.PULSE_PHASE] = 1.0;
                props[PanoramaProps.TICK_COUNT] = 0;

                return props;
            }
        }
    }
}
