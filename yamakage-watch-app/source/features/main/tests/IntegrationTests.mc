import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;
using MonkeyHooks.Touchable as MHTouchable;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Main {
        (:test)
        module IntegrationTests {
            (:test)
            function testMainRenderIntegration(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                try {
                    MainRender.render(dc, props);

                    props[MainProps.MODE] = TargetMode.MOON;
                    MainRender.render(dc, props);

                    logger.debug("MainRender integration test passed.");
                } catch (e) {
                    logger.error("MainRender crashed: " + e.getErrorMessage());
                    return false;
                }
                return true;
            }

            (:test)
            function testMainViewLifecycleIntegration(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    coreA.TARGET_MODE => TargetMode.MOON
                });

                var view = new MainView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    view.initialize();
                    view.onLayout(dc);
                    view.onShow();
                    view.onTimerTick(); // Advance tick and update GPS internally
                    view.onUpdate(dc);
                    view.onHide();

                    logger.debug("MainView lifecycle executed smoothly.");
                } catch (e) {
                    logger.error(
                        "MainView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMainViewTouchInteraction(
                logger as Test.Logger
            ) as Boolean {
                if (!System.getDeviceSettings().isTouchScreen) {
                    logger.debug(
                        "Skipped touch test (device is not touch screen)"
                    );
                    return true;
                }

                MHTest.resetStore();
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120
                });

                var view = new MainView();
                var dc = MHTest.createDummyDc(240, 240);

                view.initialize();
                view.onLayout(dc);
                view.onShow();

                var hitId = MHTouchable.handleTap(120, 192); // Center of start button
                Test.assertMessage(
                    hitId == MAIN_START_BUTTON_KEY,
                    "Expected valid ID when tapping start button coordinates"
                );

                var missId = MHTouchable.handleTap(10, 10);
                Test.assertMessage(
                    missId == null,
                    "Expected null when tapping outside button bounds"
                );

                view.onHide();
                return true;
            }
        }
    }
}
