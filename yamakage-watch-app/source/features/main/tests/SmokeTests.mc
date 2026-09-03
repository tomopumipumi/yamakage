import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;

import Features.Main.Components.MainBackground;
import Features.Main.Components.MainGpsStatus;
import Features.Main.Components.MainSettingsButton;
import Features.Main.Components.MainStartAction;
import Features.Main.Components.MainSunAnimation;
import Features.Main.Components.MainTargetSelector;
import Features.Main.Components.MainTitle;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Main {
        (:test)
        module SmokeTests {
            (:test)
            function testMainTitleRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    MainTitle.render(dc, 120, 60, Graphics.FONT_LARGE);
                    logger.debug("MainTitle.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "MainTitle.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainBackgroundRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    MainBackground.render(dc, 240, 240);
                    logger.debug(
                        "MainBackground.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "MainBackground.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainGpsStatusRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    MainGpsStatus.render(
                        dc,
                        120,
                        24,
                        "GPS: OK",
                        Graphics.COLOR_GREEN
                    );
                    logger.debug("MainGpsStatus.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "MainGpsStatus.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainTargetSelectorRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    MainTargetSelector.render(dc, 204, 84, TargetMode.SUN);
                    MainTargetSelector.render(dc, 204, 84, TargetMode.MOON);
                    logger.debug(
                        "MainTargetSelector.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "MainTargetSelector.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainStartActionRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    MainStartAction.render(
                        dc,
                        120,
                        192,
                        100,
                        40,
                        Graphics.FONT_SMALL,
                        true,
                        TargetMode.SUN
                    );
                    logger.debug(
                        "MainStartAction.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "MainStartAction.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainSunAnimationRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var sparkleBuffer = TestFixture.createSparkleBuffer();
                try {
                    MainSunAnimation.render(
                        dc,
                        0.5,
                        240,
                        240,
                        120,
                        TargetMode.SUN,
                        true,
                        sparkleBuffer
                    );
                    logger.debug(
                        "MainSunAnimation.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "MainSunAnimation.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainSunAnimationEdgeCases(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var sparkleBuffer = TestFixture.createSparkleBuffer();
                try {
                    // Out of bounds progress
                    MainSunAnimation.render(
                        dc,
                        -0.5,
                        240,
                        240,
                        120,
                        TargetMode.SUN,
                        true,
                        sparkleBuffer
                    );
                    MainSunAnimation.render(
                        dc,
                        1.5,
                        240,
                        240,
                        120,
                        TargetMode.SUN,
                        true,
                        sparkleBuffer
                    );
                    // Zero dimension edge cases
                    MainSunAnimation.render(
                        dc,
                        0.5,
                        0,
                        0,
                        0,
                        TargetMode.SUN,
                        true,
                        sparkleBuffer
                    );
                    logger.debug(
                        "MainSunAnimation edge cases handled successfully."
                    );
                } catch (e) {
                    logger.error("Edge case crashed: " + e.getErrorMessage());
                    return false;
                }
                return true;
            }
        }
    }
}
