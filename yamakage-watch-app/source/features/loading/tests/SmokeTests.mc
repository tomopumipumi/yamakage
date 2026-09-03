import Toybox.Lang;
import Toybox.Test;
import Toybox.Math;

import Features.Loading.Components.LoadingMoon;
import Features.Loading.Components.LoadingMountains;
import Features.Loading.Components.LoadingSun;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Loading {
        (:test)
        module SmokeTests {
            (:test)
            function testLoadingSunRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    LoadingSun.render(dc, 120, 120, Math.PI);
                    logger.debug("LoadingSun.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "LoadingSun.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testLoadingMoonRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    LoadingMoon.render(dc, 120, 120, Math.PI);
                    logger.debug("LoadingMoon.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "LoadingMoon.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testLoadingMountainsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    LoadingMountains.render(dc, 240, 240);
                    logger.debug(
                        "LoadingMountains.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "LoadingMountains.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
