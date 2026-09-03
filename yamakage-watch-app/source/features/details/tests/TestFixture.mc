import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Details {
        (:test)
        module TestFixture {
            function getDummyProfiles() as Array {
                // Simulates ApiSchema.AzimuthProfilesArray: [[elevation], ...]
                return [[10.0], [25.0], [30.0], [15.0], [0.0], [-5.0]];
            }

            function createDummyLayoutCtx() as Array {
                return [
                    240, // width
                    Graphics.FONT_TINY, // label font
                    Graphics.FONT_SMALL, // value font
                    Graphics.FONT_TINY // icon font (mocked)
                ];
            }

            function createDummyProps() as Array {
                var props = new [DetailsProps.DATA_SIZE];
                props[DetailsProps.W] = 240;
                props[DetailsProps.H] = 240;
                props[DetailsProps.LAYOUT_CTX] = createDummyLayoutCtx();
                props[DetailsProps.MODE] = TargetMode.SUN;
                props[DetailsProps.HAS_DATA] = true;
                props[DetailsProps.PROFILES] = getDummyProfiles();
                props[DetailsProps.STEP_DEG] = 15;
                props[DetailsProps.FRACTION] = 0.85;
                props[DetailsProps.PHASE] = 0.5;
                props[DetailsProps.SUNRISE_STR] = "06:30";
                props[DetailsProps.SUNSET_STR] = "18:45";
                props[DetailsProps.ILLUM_STR] = "85.0%";
                props[DetailsProps.LAST_HEADING] = -999.0;
                props[DetailsProps.ELEV_STR] = "25.0°";

                return props;
            }
        }
    }
}
