import Toybox.Lang;
import Toybox.Test;

import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Panorama {
        (:test)
        module IntegrationTests {
            (:test)
            function testPanoramaRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    // Test with SUN mode
                    PanoramaRender.render(dc, props);

                    // Test with MOON mode
                    props[PanoramaProps.MODE] = TargetMode.MOON;
                    PanoramaRender.render(dc, props);

                    // Test with NO DATA
                    props[PanoramaProps.HAS_DATA] = false;
                    PanoramaRender.render(dc, props);

                    logger.debug(
                        "PanoramaRender handled all integration states successfully."
                    );
                } catch (e) {
                    logger.error(
                        "PanoramaRender integration crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testPanoramaViewLifecycleIntegration(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();

                // Inject necessary core states
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    coreA.TARGET_MODE => TargetMode.SUN,
                    coreA.ICON_FONT_INDEX => 0,
                    SettingIds.ANIM_ENABLED => ToggleValues.ON
                });

                var view = new PanoramaView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    // Simulate OS lifecycle flow
                    view.initialize();
                    view.onLayout(dc); // Initializes fonts and core layout
                    view.onShow(); // Initializes buffers, fetches initial data

                    // Simulate timer tick (tickCount increments, heading fetches, background animates)
                    view.onTimerTick();

                    // Execute update which handles heading changes and mountain array rebuilds
                    view.onUpdate(dc);
                    view.onHide(); // Unsubscribes and cleans up buffers

                    logger.debug(
                        "PanoramaView lifecycle integrated correctly."
                    );
                } catch (e) {
                    logger.error(
                        "PanoramaView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }
        }
    }
}
