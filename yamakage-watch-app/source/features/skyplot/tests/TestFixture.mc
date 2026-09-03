import Toybox.Lang;
import Toybox.Graphics;

import Shared.Core.Enums.TargetMode;

module Features {
    module SkyPlot {
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

            function createDummyProps() as Array {
                var props = new [SkyPlotProps.DATA_SIZE];
                props[SkyPlotProps.W] = 240;
                props[SkyPlotProps.H] = 240;
                props[SkyPlotProps.CX] = 120;
                props[SkyPlotProps.CY] = 120;
                props[SkyPlotProps.RADIUS] = 90.0;
                props[SkyPlotProps.N_FONT] = Graphics.FONT_TINY;
                props[SkyPlotProps.ICON_FONT] = Graphics.FONT_TINY; // Using tiny as mock icon font
                props[SkyPlotProps.IS_ANIM_ON] = true;
                props[SkyPlotProps.MODE] = TargetMode.SUN;
                props[SkyPlotProps.CLOUD_BUFFER] = _createFilledArray(20);
                props[SkyPlotProps.STAR_BUFFER] = _createFilledArray(60);
                props[SkyPlotProps.HAS_DATA] = true;
                props[SkyPlotProps.STEP_DEG] = 15;
                props[SkyPlotProps.PROFILES] = getDummyProfiles();
                props[SkyPlotProps.PATHS] = getDummyPaths();
                props[SkyPlotProps.FRACTION] = 0.5;
                props[SkyPlotProps.PHASE] = 0.5;
                props[SkyPlotProps.PULSE_PHASE] = 1.0;
                props[SkyPlotProps.HEADING] = 45.0;

                return props;
            }
        }
    }
}
