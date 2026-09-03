import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.Math;

using MonkeyHooks.TestUtils as MHTest;

import Shared.Ui.Button;
import Shared.Ui.MoonIcon;
import Shared.Ui.PageIndicator;
import Shared.Ui.SonarPulse;
import Shared.Ui.SunIcon;
import Shared.Ui.TextLabel;
import Shared.Ui.Toggle;
import Shared.Ui.ValueSelector;

module Shared {
    module Ui {
        (:test)
        module SmokeTests {
            (:test)
            function testButtonRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    Button.render(
                        dc,
                        "TEST",
                        120,
                        120,
                        100,
                        40,
                        Graphics.FONT_SMALL,
                        Graphics.COLOR_BLUE,
                        Graphics.COLOR_WHITE
                    );
                    logger.debug("Button.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "Button.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMoonIconRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    // Test typical fraction and phase
                    MoonIcon.render(dc, 120, 120, 0.5, 0.5, 20);
                    // Test edge cases (New Moon and Full Moon)
                    MoonIcon.render(dc, 120, 120, 0.0, 0.0, 20);
                    MoonIcon.render(dc, 120, 120, 1.0, 0.5, 20);
                    logger.debug("MoonIcon.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "MoonIcon.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testPageIndicatorRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    PageIndicator.render(dc, 5, 2, 240, 240);
                    logger.debug("PageIndicator.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "PageIndicator.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testSonarPulseRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    SonarPulse.render(
                        dc,
                        120,
                        120,
                        Math.PI,
                        Graphics.COLOR_YELLOW
                    );
                    logger.debug("SonarPulse.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "SonarPulse.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testSunIconRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    SunIcon.render(dc, 120, 120);
                    logger.debug("SunIcon.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "SunIcon.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testTextLabelRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    TextLabel.render(
                        dc,
                        "LABEL",
                        120,
                        120,
                        Graphics.FONT_MEDIUM
                    );
                    logger.debug("TextLabel.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "TextLabel.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testToggleRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    // Test branch where toggle is ON and SELECTED
                    Toggle.render(dc, 20, 100, 200, 44, "Option 1", true, true);
                    // Test branch where toggle is OFF and NOT SELECTED
                    Toggle.render(
                        dc,
                        20,
                        100,
                        200,
                        44,
                        "Option 2",
                        false,
                        false
                    );
                    logger.debug("Toggle.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "Toggle.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testValueSelectorRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    // Test branch where selector is SELECTED
                    ValueSelector.render(
                        dc,
                        20,
                        100,
                        200,
                        44,
                        "Speed",
                        "Fast",
                        true
                    );
                    // Test branch where selector is NOT SELECTED
                    ValueSelector.render(
                        dc,
                        20,
                        100,
                        200,
                        44,
                        "Speed",
                        "Slow",
                        false
                    );
                    logger.debug("ValueSelector.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "ValueSelector.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
