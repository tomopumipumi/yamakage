import Toybox.Lang;
import Toybox.Test;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Panorama {
        (:test)
        module LogicTests {
            (:test)
            function testPanoramaLogicDegreeWrapping(
                logger as Test.Logger
            ) as Boolean {
                var width = 240;

                // Test 1: Within normal field of view (straight ahead)
                // Heading: 180 (South), Target: 180 -> Should be centered on the screen (X = 120)
                var xCenter = PanoramaLogic.getLabelXPos(180.0, 180.0, width);
                Test.assertEqualMessage(
                    xCenter,
                    120,
                    "Target exactly at heading should be centered."
                );

                // Test 2: Wrap-around calculation across North (0/360 degrees) (Critical)
                // Heading: 10 deg, Target: 350 deg -> Should appear at -20 deg (left side of the screen)
                var xWrapLeft = PanoramaLogic.getLabelXPos(350.0, 10.0, width);
                Test.assertEqualMessage(
                    xWrapLeft != null,
                    true,
                    "350 deg should be visible when heading is 10 deg (wrapping)."
                );
                Test.assertEqualMessage(
                    xWrapLeft < 120,
                    true,
                    "Target should appear on the left side of the screen."
                );

                // Heading: 350 deg, Target: 10 deg -> Should appear at +20 deg (right side of the screen)
                var xWrapRight = PanoramaLogic.getLabelXPos(10.0, 350.0, width);
                Test.assertEqualMessage(
                    xWrapRight != null,
                    true,
                    "10 deg should be visible when heading is 350 deg (wrapping)."
                );
                Test.assertEqualMessage(
                    xWrapRight > 120,
                    true,
                    "Target should appear on the right side of the screen."
                );

                // Test 3: Exclusion check outside the Field of View (FOV 90 deg)
                // Heading: 180 deg, Target: 90 deg -> Outside FOV, should return null
                var xOut = PanoramaLogic.getLabelXPos(90.0, 180.0, width);
                Test.assertMessage(
                    xOut == null,
                    "Target outside of FOV should return null."
                );

                logger.debug("PanoramaLogic degree wrapping tests passed.");
                return true;
            }

            (:test)
            function testPanoramaLogicElevationMath(
                logger as Test.Logger
            ) as Boolean {
                var height = 240;

                var y0 = PanoramaLogic.getYFromElevation(0.0, height);
                var y90 = PanoramaLogic.getYFromElevation(90.0, height);
                var yNegative = PanoramaLogic.getYFromElevation(-10.0, height);

                // In Garmin's coordinate system, the Y-axis increases downwards,
                // so an elevation of 0 degrees (horizon) should have a larger Y-pixel value than 90 degrees (zenith).
                Test.assertEqualMessage(
                    y0 > y90,
                    true,
                    "Elevation 0 should have a larger Y pixel value than Elevation 90."
                );

                // If the elevation is negative, it should render further down (larger Y) than the horizon.
                Test.assertEqualMessage(
                    yNegative > y0,
                    true,
                    "Negative elevation should render below horizon."
                );

                logger.debug("PanoramaLogic elevation math tests passed.");
                return true;
            }
        }
    }
}
