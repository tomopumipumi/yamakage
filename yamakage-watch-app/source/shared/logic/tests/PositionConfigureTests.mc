import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;

using MonkeyHooks as MH;
using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

import Shared.Logic.PositionConfigure;

module Shared {
    module Logic {
        (:test)
        module PositionConfigureTests {
            (:test)
            function testPositionConfigureInitialization(
                logger as Test.Logger
            ) as Boolean {
                MHTest.resetStore();
                var dc = MHTest.createDummyDc(260, 260);

                PositionConfigure.initializeGlobalLayout(dc);

                var cx = MH.useNumber(coreA.CENTER_X).get();
                var cy = MH.useNumber(coreA.CENTER_Y).get();

                Test.assertMessage(
                    cx != null && cx == 130,
                    "CENTER_X should be initialized to exactly half of DC width (130)."
                );
                Test.assertMessage(
                    cy != null && cy == 130,
                    "CENTER_Y should be initialized to exactly half of DC height (130)."
                );

                var dcSmall = MHTest.createDummyDc(200, 200);
                PositionConfigure.initializeGlobalLayout(dcSmall);

                var cxAfter = MH.useNumber(coreA.CENTER_X).get();
                Test.assertMessage(
                    cxAfter == 130,
                    "Values should NOT be overwritten on subsequent calls."
                );

                logger.debug(
                    "PositionConfigure.initializeGlobalLayout passed."
                );
                return true;
            }
        }
    }
}
