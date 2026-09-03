import Toybox.Lang;
import Toybox.Test;

module Features {
    module SkyPlot {
        (:test)
        module LogicTests {
            (:test)
            function testSkyPlotPolarMath(logger as Test.Logger) as Boolean {
                var cx = 120;
                var cy = 120;
                var radius = 100.0;

                // Test A: Zenith (Elevation 90 deg) -> Should be at screen center (cx, cy)
                var posZenith =
                    Features.SkyPlot.SkyPlotLogic.getPolarCoordinates(
                        0.0,
                        90.0,
                        cx,
                        cy,
                        radius
                    );
                Test.assertEqualMessage(
                    posZenith[0],
                    cx,
                    "Zenith (90 deg) should be at center X."
                );
                Test.assertEqualMessage(
                    posZenith[1],
                    cy,
                    "Zenith (90 deg) should be at center Y."
                );

                // Test B: East on the horizon (Elevation 0 deg, Azimuth 90 deg) -> Should be at the right edge
                var posEast = Features.SkyPlot.SkyPlotLogic.getPolarCoordinates(
                    90.0,
                    0.0,
                    cx,
                    cy,
                    radius
                );
                Test.assertEqualMessage(
                    posEast[0],
                    cx + radius.toNumber(),
                    "Azimuth 90 (East) should be at right edge."
                );
                Test.assertEqualMessage(
                    posEast[1],
                    cy,
                    "East should maintain center Y."
                );

                // Test C: Edge case (Negative elevation) -> Should be clamped to 0 deg and stay on the circle edge
                var posBelowHorizon =
                    Features.SkyPlot.SkyPlotLogic.getPolarCoordinates(
                        180.0,
                        -10.0,
                        cx,
                        cy,
                        radius
                    );
                Test.assertEqualMessage(
                    posBelowHorizon[1],
                    cy + radius.toNumber(),
                    "Negative elevation should be clamped to edge radius."
                );

                logger.debug("SkyPlot polar math verified.");
                return true;
            }
        }
    }
}
