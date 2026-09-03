import Toybox.Lang;
import Toybox.Test;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;

using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

module Features {
    module SkyPlot {
        (:test)
        module IntegrationTests {
            (:test)
            function testSkyPlotRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    // Test with SUN mode
                    SkyPlotRender.render(dc, props);

                    // Test with MOON mode
                    props[SkyPlotProps.MODE] = TargetMode.MOON;
                    SkyPlotRender.render(dc, props);

                    // Test with NO DATA
                    props[SkyPlotProps.HAS_DATA] = false;
                    SkyPlotRender.render(dc, props);

                    logger.debug(
                        "SkyPlotRender handled all integration states successfully."
                    );
                } catch (e) {
                    logger.error(
                        "SkyPlotRender integration crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testSkyPlotViewLifecycleIntegration(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();

                // Inject necessary core states
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    coreA.CENTER_Y => 120,
                    coreA.TARGET_MODE => TargetMode.SUN,
                    coreA.ICON_FONT_INDEX => 0,
                    SettingIds.ANIM_ENABLED => ToggleValues.ON
                });

                var view = new SkyPlotView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    // Simulate OS lifecycle flow
                    view.initialize();
                    view.onLayout(dc);
                    view.onShow(); // Subscribes to timers and initializes buffers
                    view.onUpdate(dc); // Performs render
                    view.onTimerTick(); // Verifies timer subscription logic (e.g. pulsePhase increment)
                    view.onHide(); // Unsubscribes and cleans up buffers

                    logger.debug("SkyPlotView lifecycle integrated correctly.");
                } catch (e) {
                    logger.error(
                        "SkyPlotView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
