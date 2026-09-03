import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

using MonkeyHooks.TestUtils as MHTest;
using MonkeyHooks.Touchable as MHTouchable;
using Core.AppArena.CoreArena as coreA;

module Features {
    module Settings {
        (:test)
        module IntegrationTests {
            (:test)
            function testSettingsViewLifecycleIntegration(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();
                MHTest.injectState({
                    coreA.DISPLAY_WIDTH => 240,
                    coreA.DISPLAY_HEIGHT => 240,
                    coreA.CENTER_X => 120,
                    :settings_cursor => 0,
                    SettingIds.ANIM_ENABLED => ToggleValues.ON,
                    SettingIds.FRAME_RATE => 0
                });

                var view = new SettingsView();
                var dc = MHTest.createDummyDc(240, 240);

                try {
                    view.initialize();
                    view.onLayout(dc);
                    view.onShow();
                    view.onUpdate(dc);
                    view.onHide();
                    logger.debug("SettingsView lifecycle executed smoothly.");
                } catch (e) {
                    logger.error(
                        "SettingsView lifecycle crashed: " + e.getErrorMessage()
                    );
                    return false;
                }

                return true;
            }

            (:test)
            function testSettingsViewTouchInteraction(
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

                var view = new SettingsView();
                var dc = MHTest.createDummyDc(240, 240);

                view.initialize();
                view.onLayout(dc);
                view.onShow();

                // When h = 240, START_Y = (240 * 0.28) = 67
                // ROW_HEIGHT = 44, SPACING = 8

                // [Test Case A: Tap near the center of the first setting item (Index 0)]
                // Range: Y = 67 to 111 (Center: ~89)
                var hitId0 = MHTouchable.handleTap(120, 89);
                Test.assertEqualMessage(
                    hitId0,
                    0,
                    "First item should be correctly detected as Index 0"
                );

                // [Test Case B: Tap near the center of the second setting item (Index 1)]
                // Range: Y = 119 to 163 (Center: ~141)
                var hitId1 = MHTouchable.handleTap(120, 141);
                Test.assertEqualMessage(
                    hitId1,
                    1,
                    "Second item should be correctly detected as Index 1"
                );

                // [Test Case C: Tap the gap between items (SPACING) or the top area]
                var missId = MHTouchable.handleTap(120, 10);
                Test.assertMessage(
                    missId == null,
                    "Tapping outside the button bounds should return null"
                );

                view.onHide();
                return true;
            }
        }
    }
}
