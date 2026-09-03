import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;

import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaBackground;
import Features.Panorama.Components.PanoramaLabels;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaMoonEvents;
import Features.Panorama.Components.PanoramaMoonPath;
import Features.Panorama.Components.PanoramaSunPath;
import Features.Panorama.Components.PanoramaSunEvents;

import Features.Panorama.TestFixture;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Panorama {
        (:test)
        module SmokeTests {
            (:test)
            function testPanoramaLogicMath(logger as Test.Logger) as Boolean {
                // Test Y calculation (horizon should be lower part of screen)
                var y0 = PanoramaLogic.getYFromElevation(0.0, 240);
                var y90 = PanoramaLogic.getYFromElevation(90.0, 240);

                Test.assertEqualMessage(
                    y0 > y90,
                    true,
                    "Elevation 0 should be rendered lower (higher Y) than elevation 90"
                );

                // Test label X position calculation
                var xPos = PanoramaLogic.getLabelXPos(180.0, 180.0, 240);
                Test.assertEqualMessage(
                    xPos,
                    120,
                    "Label matching heading should be at the center of the screen (120)"
                );

                var outOfBoundsX = PanoramaLogic.getLabelXPos(0.0, 180.0, 240);
                Test.assertMessage(
                    outOfBoundsX == null,
                    "Label outside FOV should return null"
                );

                logger.debug("PanoramaLogic math executed successfully.");
                return true;
            }

            (:test)
            function testPanoramaGridRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    PanoramaGrid.render(dc, 240, 240);
                    logger.debug("PanoramaGrid.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "PanoramaGrid.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testPanoramaBackgroundRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var cloudBuffer =
                    props[PanoramaProps.CLOUD_BUFFER] as Array<Float>;
                var starBuffer =
                    props[PanoramaProps.STAR_BUFFER] as Array<Float>;

                try {
                    // Mode 0 = Clouds, Mode 1 = Stars
                    PanoramaBackground.render(dc, 0, cloudBuffer);
                    PanoramaBackground.render(dc, 1, starBuffer);
                    logger.debug(
                        "PanoramaBackground.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "PanoramaBackground.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testPanoramaLabelsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    PanoramaLabels.render(dc, 180.0, 240, 240, 120);
                    logger.debug(
                        "PanoramaLabels.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "PanoramaLabels.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testPanoramaMountainsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var points = TestFixture.getDummyMountainPoints();
                try {
                    PanoramaMountains.render(dc, points, 240);
                    logger.debug(
                        "PanoramaMountains.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "PanoramaMountains.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testPanoramaPathsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                try {
                    PanoramaSunPath.render(dc, paths, 180.0, 240, 240, 1.0);
                    PanoramaMoonPath.render(
                        dc,
                        paths,
                        180.0,
                        240,
                        240,
                        0.5,
                        0.5,
                        1.0
                    );
                    logger.debug("Panorama paths rendered successfully.");
                } catch (e) {
                    logger.error(
                        "Panorama paths crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testPanoramaEventsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iconFont = Graphics.FONT_TINY;
                try {
                    PanoramaSunEvents.render(
                        dc,
                        paths,
                        180.0,
                        240,
                        240,
                        iconFont
                    );
                    PanoramaMoonEvents.render(
                        dc,
                        paths,
                        180.0,
                        240,
                        240,
                        iconFont
                    );
                    logger.debug("Panorama events rendered successfully.");
                } catch (e) {
                    logger.error(
                        "Panorama events crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
