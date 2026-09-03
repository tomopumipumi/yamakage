import Toybox.Lang;
import Toybox.Test;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Error {
        (:test)
        module IntegrationTests {
            (:test)
            function testErrorRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    ErrorRender.render(dc, props);
                    logger.debug(
                        "ErrorRender handled integration state successfully."
                    );
                } catch (e) {
                    logger.error(
                        "ErrorRender integration crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testErrorViewLifecycleAndReactivity(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();

                // Inject necessary core states
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    SettingIds.ANIM_ENABLED => ToggleValues.ON,
                    coreA.LAST_ERROR => "GPS Signal Lost"
                });

                var view = new ErrorView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    // Simulate OS lifecycle flow
                    view.initialize();
                    view.onLayout(dc); // Initializes layout
                    view.onShow(); // Subscribes to states and timers

                    // Simulate timer tick (animation pulse increments)
                    view.onTimerTick();
                    view.onUpdate(dc);

                    // Simulate a reactive state change in the Store (e.g. error message updates dynamically)
                    MHTest.injectState({
                        coreA.LAST_ERROR => "Server Error 500"
                    });
                    view.onErrorChanged(["Server Error 500"]);

                    // Render again to ensure the updated prop doesn't crash the renderer
                    view.onUpdate(dc);

                    view.onHide(); // Unsubscribes and cleans up

                    logger.debug(
                        "ErrorView lifecycle and reactivity handled correctly."
                    );
                } catch (e) {
                    logger.error(
                        "ErrorView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
