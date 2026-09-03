import Toybox.Lang;
import Toybox.Test;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Radar {
        (:test)
        module IntegrationTests {
            (:test)
            function testRadarRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    // Test with SUN mode
                    RadarRender.render(dc, props);

                    // Test with MOON mode
                    props[RadarProps.MODE] = TargetMode.MOON;
                    RadarRender.render(dc, props);

                    // Test with NO DATA
                    props[RadarProps.HAS_DATA] = false;
                    RadarRender.render(dc, props);

                    logger.debug(
                        "RadarRender handled all integration states successfully."
                    );
                } catch (e) {
                    logger.error(
                        "RadarRender integration crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testRadarViewLifecycleIntegration(
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
                    SettingIds.ANIM_ENABLED => ToggleValues.ON
                });

                var view = new RadarView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    // Simulate OS lifecycle flow
                    view.initialize();
                    view.onLayout(dc); // Initializes fonts and core layout
                    view.onShow(); // Subscribes to timers, fetches initial sweep angle

                    // Simulate timer tick (sweepAngle should increment)
                    view.onTimerTick();

                    view.onUpdate(dc); // Performs render with updated sweep angle
                    view.onHide(); // Unsubscribes and cleans up

                    //throw new Lang.Exception("Intentional test error");

                    logger.debug("RadarView lifecycle integrated correctly.");
                } catch (e) {
                    logger.error(
                        "RadarView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
