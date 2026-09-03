import Toybox.Lang;
import Toybox.Test;
import Features.Settings.TestFixture;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Settings {
        (:test)
        module SmokeTests {
            (:test)
            function testSettingsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    SettingsRender.render(dc, props);
                    logger.debug("SettingsRender executed successfully.");
                } catch (e) {
                    logger.error(
                        "SettingsRender crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
