import Toybox.Lang;
import Toybox.Test;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Main {
        (:test)
        module LogicTests {
            (:test)
            function testMainLogicCalculateSunPosition(
                logger as Test.Logger
            ) as Boolean {
                var cx = 120;
                var cy = 120;
                var radius = 100.0;

                // Progress 0.0 (Sunrise): Angle is PI (180 degrees)
                // x = 120 + 100*cos(180) = 20
                // y = 120 - 100*sin(180) = 120
                var posRise = MainLogic.calculateSunPosition(
                    0.0,
                    cx,
                    cy,
                    radius
                );
                Test.assertEqualMessage(
                    posRise[0],
                    20,
                    "Progress 0.0 should be at left edge of radius."
                );
                Test.assertEqualMessage(
                    posRise[1],
                    120,
                    "Progress 0.0 should be at horizontal center."
                );

                // Progress 0.5 (Solar Noon): Angle is PI/2 (90 degrees)
                // x = 120 + 100*cos(90) = 120
                // y = 120 - 100*sin(90) = 20
                var posPeak = MainLogic.calculateSunPosition(
                    0.5,
                    cx,
                    cy,
                    radius
                );
                Test.assertEqualMessage(
                    posPeak[0],
                    120,
                    "Progress 0.5 should be at vertical center."
                );
                Test.assertEqualMessage(
                    posPeak[1],
                    20,
                    "Progress 0.5 should be at highest point."
                );

                // Progress 1.0 (Sunset): Angle is 0 degrees
                // x = 120 + 100*cos(0) = 220
                // y = 120 - 100*sin(0) = 120
                var posSet = MainLogic.calculateSunPosition(
                    1.0,
                    cx,
                    cy,
                    radius
                );
                Test.assertEqualMessage(
                    posSet[0],
                    220,
                    "Progress 1.0 should be at right edge of radius."
                );

                logger.debug("MainLogic sun position math tests passed.");
                return true;
            }

            (:test)
            function testMainLogicUpdateSparkles(
                logger as Test.Logger
            ) as Boolean {
                // Array length boundary: Logic assumes the number of elements is a multiple of 3.
                // Verify that passing an extremely short buffer does not cause a crash.
                var shortBuffer = [0, 0, 0] as Array<Number>;

                try {
                    // Update with target set to x=100, y=100
                    MainLogic.updateSparkles(shortBuffer, 100, 100);

                    // Since lifetime reaches zero, re-initialization triggers and coordinates around the target should be set
                    var initializedX = shortBuffer[0];
                    var initializedY = shortBuffer[1];
                    var initializedLife = shortBuffer[2].toFloat();

                    Test.assertEqualMessage(
                        initializedLife > 0.0,
                        true,
                        "Particle life should be initialized."
                    );
                    Test.assertEqualMessage(
                        (initializedX - 100).abs() <= 15,
                        true,
                        "X should be around target."
                    );
                    Test.assertEqualMessage(
                        (initializedY - 100).abs() <= 15,
                        true,
                        "Y should be around target."
                    );

                    logger.debug("MainLogic updateSparkles executed safely.");
                } catch (e) {
                    logger.error(
                        "MainLogic updateSparkles crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
