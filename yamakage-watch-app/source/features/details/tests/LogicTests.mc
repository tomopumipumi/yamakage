import Toybox.Lang;
import Toybox.Test;

module Features {
    module Details {
        (:test)
        module LogicTests {
            (:test)
            function testDetailsLogicFormatting(
                logger as Test.Logger
            ) as Boolean {
                // 1. Illumination Formatting
                var illumStr = DetailsLogic.formatIllumination(0.854);
                Test.assertMessage(
                    illumStr.equals("85.4%"),
                    "Illumination should format to 1 decimal place percentage."
                );

                // 2. Elevation String Logic
                var profiles = TestFixture.getDummyProfiles();
                var stepDeg = 15;

                // Match case (15 deg -> Index 1 -> 25.0)
                var elevStrMatch = DetailsLogic.getElevationString(
                    profiles,
                    stepDeg,
                    15.0
                );
                Test.assertMessage(
                    elevStrMatch.equals("25.0°"),
                    "Should extract correct elevation at 15 deg heading."
                );

                // Out of bounds case (350 deg -> Index 23)
                var elevStrOutOfBounds = DetailsLogic.getElevationString(
                    profiles,
                    stepDeg,
                    350.0
                );
                Test.assertMessage(
                    elevStrOutOfBounds.equals("--"),
                    "Should return '--' for out of bounds heading."
                );

                // Null profiles case
                var elevStrNull = DetailsLogic.getElevationString(
                    null,
                    stepDeg,
                    15.0
                );
                Test.assertMessage(
                    elevStrNull.equals("--"),
                    "Should return '--' if profiles are null."
                );

                logger.debug("DetailsLogic formatting executed successfully.");
                return true;
            }

            // 3. Delegate Routing Logic Test
            (:test)
            function testDetailsDelegateRouting(
                logger as Test.Logger
            ) as Boolean {
                var delegate = new DetailsDelegate();

                // The delegate methods should return true (event consumed)
                Test.assertMessage(
                    delegate.onBack() == true,
                    "onBack should return true"
                );
                Test.assertMessage(
                    delegate.onPreviousPage() == true,
                    "onPreviousPage should return true"
                );
                Test.assertMessage(
                    delegate.onNextPage() == true,
                    "onNextPage should return true"
                );

                logger.debug("DetailsDelegate routing tested successfully.");
                return true;
            }
        }
    }
}
