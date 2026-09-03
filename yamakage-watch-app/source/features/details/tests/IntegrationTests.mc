import Toybox.Lang;
import Toybox.Test;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Details {
        (:test)
        module IntegrationTests {
            (:test)
            function testDetailsRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    // Test with SUN mode
                    DetailsRender.render(dc, props);

                    // Test with MOON mode
                    props[DetailsProps.MODE] = TargetMode.MOON;
                    DetailsRender.render(dc, props);

                    // Test with NO DATA
                    props[DetailsProps.HAS_DATA] = false;
                    DetailsRender.render(dc, props);

                    logger.debug(
                        "DetailsRender handled all integration states successfully."
                    );
                } catch (e) {
                    logger.error(
                        "DetailsRender integration crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testDetailsViewLifecycleIntegration(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();

                // Inject necessary core states
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    coreA.TARGET_MODE => TargetMode.MOON,
                    coreA.ICON_FONT_INDEX => 0
                });

                var view = new DetailsView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    // Simulate OS lifecycle flow
                    view.initialize();
                    view.onLayout(dc); // Initializes layout context and fonts
                    view.onShow(); // Fetches API payload from context and formats strings

                    // Simulate timer tick (triggers UI update)
                    view.onTimerTick();

                    // Execute update, which updates compass heading and triggers DetailsRender
                    view.onUpdate(dc);

                    view.onHide(); // Unsubscribes and cleans up context

                    logger.debug("DetailsView lifecycle integrated correctly.");
                } catch (e) {
                    logger.error(
                        "DetailsView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
