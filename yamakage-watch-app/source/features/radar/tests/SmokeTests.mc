import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.Math;

import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarBeam;
import Features.Radar.Components.RadarMoon;
import Features.Radar.Components.RadarSun;
import Features.Radar.Components.RadarSonarPulse;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Radar {
        (:test)
        module SmokeTests {
            (:test)
            function testRadarGridRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    RadarGrid.render(dc, 120, 120, 90.0, Graphics.FONT_TINY);
                    logger.debug("RadarGrid.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "RadarGrid.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testRadarAreaRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                try {
                    RadarArea.render(dc, profiles, 15, 120, 120, 90.0);
                    logger.debug("RadarArea.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "RadarArea.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testRadarBeamRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                try {
                    RadarBeam.render(dc, 45.0, profiles, 15, 120, 120, 90.0);
                    logger.debug("RadarBeam.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "RadarBeam.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testRadarSonarPulseRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    RadarSonarPulse.render(dc, 120, 120, 90.0, Math.PI);
                    logger.debug(
                        "RadarSonarPulse.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "RadarSonarPulse.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testRadarTargetsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                try {
                    RadarSun.render(dc, paths, 120, 120, 90.0);
                    RadarMoon.render(dc, paths, 120, 120, 90.0, 0.5, 0.5);
                    logger.debug(
                        "Radar targets (Sun/Moon) rendered successfully."
                    );
                } catch (e) {
                    logger.error(
                        "Radar targets crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
