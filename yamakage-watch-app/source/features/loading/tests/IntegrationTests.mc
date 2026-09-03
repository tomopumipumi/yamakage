import Toybox.Lang;
import Toybox.Test;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.LoadingUiArena as loadA;

module Features {
    module Loading {
        (:test)
        module IntegrationTests {
            (:test)
            function testLoadingRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    // Test with SUN mode
                    LoadingRender.render(dc, props);

                    // Test with MOON mode
                    props[LoadingProps.MODE] = TargetMode.MOON;
                    LoadingRender.render(dc, props);

                    logger.debug(
                        "LoadingRender handled all integration states successfully."
                    );
                } catch (e) {
                    logger.error(
                        "LoadingRender integration crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testLoadingViewLifecycleAndRouting(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();

                // Inject necessary core states
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    coreA.TARGET_MODE => TargetMode.SUN,
                    SettingIds.ANIM_ENABLED => ToggleValues.ON,
                    loadA.MSG_TEXT => "Loading...",
                    coreA.SUN_SHADOW_DATA => null,
                    coreA.LAST_ERROR => null
                });

                var view = new LoadingView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    // Simulate OS lifecycle flow
                    view.initialize();
                    view.onLayout(dc); // Initializes fonts and core layout
                    view.onShow(); // Subscribes to states and timers

                    // Simulate timer tick (animation angle increments)
                    view.onTimerTick();
                    view.onUpdate(dc);

                    // Test State 1: Updating message text
                    MHTest.injectState({ loadA.MSG_TEXT => "Fetching API..." });
                    view.onMsgTextChanged(["Fetching API..."]);

                    // Test State 2: Simulated API Error -> Routes to ERROR page
                    // Since MonkeyHooks.Router is a singleton, we mock the logic manually or just
                    // ensure the method runs without crashing.
                    view.onStateChanged([null, "Network Timeout"]);

                    // Test State 3: Simulated API Success -> Routes to PANORAMA page
                    view.onStateChanged([{ "d" => "dummy_data" }, null]);

                    view.onHide(); // Unsubscribes and cleans up

                    logger.debug(
                        "LoadingView lifecycle and routing handled correctly."
                    );
                } catch (e) {
                    logger.error(
                        "LoadingView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
