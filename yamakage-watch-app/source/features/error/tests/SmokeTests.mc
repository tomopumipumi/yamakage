import Toybox.Lang;
import Toybox.Test;
import Toybox.Math;

import Features.Error.Components.ErrorIcon;
import Features.Error.Components.ErrorMessage;
import Features.Error.Components.ErrorMountains;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Error {
        (:test)
        module SmokeTests {
            (:test)
            function testErrorIconRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    ErrorIcon.render(dc, 120, 84, Math.PI);
                    logger.debug("ErrorIcon.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "ErrorIcon.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testErrorMessageRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    ErrorMessage.render(dc, 120, 132, 180, "Network Timeout");
                    logger.debug("ErrorMessage.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "ErrorMessage.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testErrorMountainsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    ErrorMountains.render(dc, 240, 240);
                    logger.debug(
                        "ErrorMountains.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "ErrorMountains.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
