import Toybox.Lang;
import Toybox.Test;

import Features.Radar.RadarLogic;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Radar {
        (:test)
        module LogicTests {
            // ==================================================
            // Distance Formatting Tests
            // ==================================================
            (:test)
            function testRadarLogicFormatDistance(
                logger as Test.Logger
            ) as Boolean {
                // Normal case
                Test.assertEqualMessage(
                    RadarLogic.formatDistance(15400.0),
                    "15.4km",
                    "Should format valid distance correctly."
                );
                Test.assertEqualMessage(
                    RadarLogic.formatDistance(9900.0),
                    "9.9km",
                    "Should format under 10km correctly."
                );

                // Out of bounds (Over max)
                Test.assertEqualMessage(
                    RadarLogic.formatDistance(35000.0),
                    ">30km",
                    "Should format exceeded distance as >30km."
                );
                Test.assertEqualMessage(
                    RadarLogic.formatDistance(30000.0),
                    ">30km",
                    "Exactly 30km boundary should return >30km."
                );

                // Out of bounds (Zero or Negative - usually means no data or error)
                Test.assertEqualMessage(
                    RadarLogic.formatDistance(0.0),
                    ">30km",
                    "Zero distance should return >30km."
                );
                Test.assertEqualMessage(
                    RadarLogic.formatDistance(-1500.0),
                    ">30km",
                    "Negative distance should return >30km."
                );

                logger.debug("RadarLogic formatDistance tests passed.");
                return true;
            }

            // ==================================================
            // Polar Coordinates Math Tests
            // ==================================================
            (:test)
            function testRadarLogicPolarCoordinates(
                logger as Test.Logger
            ) as Boolean {
                var cx = 100;
                var cy = 100;
                var maxRadius = 100.0;

                // Test A: Math correctness for directions
                // North (0 deg), distance 15km (half of 30km max) -> r = 50
                var posNorth = RadarLogic.getPolarCoordinates(
                    0.0,
                    15000.0,
                    cx,
                    cy,
                    maxRadius
                );
                Test.assertEqualMessage(
                    posNorth[0] as Number,
                    100,
                    "North (0 deg) should stay on center X."
                );
                Test.assertEqualMessage(
                    posNorth[1] as Number,
                    50,
                    "North (0 deg) should be above center Y (cy - 50)."
                );

                // East (90 deg), distance 30km (max) -> r = 100
                var posEast = RadarLogic.getPolarCoordinates(
                    90.0,
                    30000.0,
                    cx,
                    cy,
                    maxRadius
                );
                Test.assertEqualMessage(
                    posEast[0] as Number,
                    200,
                    "East (90 deg) should be at right edge (cx + 100)."
                );
                Test.assertEqualMessage(
                    posEast[1] as Number,
                    100,
                    "East (90 deg) should stay on center Y."
                );

                // Test B: Distance clipping (edge cases)
                // Over max distance -> Should be clipped to maxRadius
                var posOver = RadarLogic.getPolarCoordinates(
                    180.0,
                    50000.0,
                    cx,
                    cy,
                    maxRadius
                );
                Test.assertEqualMessage(
                    posOver[1] as Number,
                    200,
                    "Exceeded distance should be clamped to maxRadius (South edge)."
                );

                // Zero or negative distance -> Logic treats as invalid and pushes to edge
                var posNegative = RadarLogic.getPolarCoordinates(
                    270.0,
                    -500.0,
                    cx,
                    cy,
                    maxRadius
                );
                Test.assertEqualMessage(
                    posNegative[0] as Number,
                    0,
                    "Negative distance should be clamped to edge (West edge)."
                );

                logger.debug("RadarLogic getPolarCoordinates tests passed.");
                return true;
            }

            // ==================================================
            // Icon Coordinates (Offset) Tests
            // ==================================================
            (:test)
            function testRadarLogicIconCoordinates(
                logger as Test.Logger
            ) as Boolean {
                var cx = 100;
                var cy = 100;
                var radius = 100.0;
                var offset = 15; // Padding for the icon to sit outside the radar

                // South (180 deg) -> Expected distance from center is radius + offset (115)
                var iconPos = RadarLogic.getIconCoordinates(
                    180.0,
                    cx,
                    cy,
                    radius,
                    offset
                );
                Test.assertEqualMessage(
                    iconPos[0] as Number,
                    100,
                    "South icon should stay on center X."
                );
                Test.assertEqualMessage(
                    iconPos[1] as Number,
                    215,
                    "South icon should be placed at cy + radius + offset."
                );

                logger.debug("RadarLogic getIconCoordinates tests passed.");
                return true;
            }
        }
    }
}
