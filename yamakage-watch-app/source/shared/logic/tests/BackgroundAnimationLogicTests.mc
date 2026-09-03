import Toybox.Lang;
import Toybox.Test;
import Toybox.System;

using MonkeyHooks as MH;
using MonkeyHooks.TestUtils as MHTest;
using Core.AppArena.CoreArena as coreA;

import Shared.Core.Enums.TargetMode;
import Shared.Icons;

import Shared.Logic.BackgroundAnimationLogic;

module Shared {
    module Logic {
        (:test)
        module BackgroundAnimationLogicTests {
            (:test)
            function testUpdateCloudsLogic(logger as Test.Logger) as Boolean {
                var w = 240;
                var h = 240;
                var buffer = [0.0, 0.0, 0.0, 0.0] as Array<Float>;

                BackgroundAnimationLogic.updateClouds(buffer, w, h, false);

                Test.assertMessage(
                    buffer[3] > 0.0,
                    "Cloud size should be initialized with a random value > 0."
                );

                var initialX = buffer[0];

                BackgroundAnimationLogic.updateClouds(buffer, w, h, true);

                Test.assertMessage(
                    buffer[0] > initialX,
                    "Cloud X position should increase when animation is ON."
                );

                logger.debug("BackgroundAnimationLogic.updateClouds passed.");
                return true;
            }

            (:test)
            function testUpdateStarsLogic(logger as Test.Logger) as Boolean {
                var w = 240;
                var h = 240;
                var buffer = [0.0, 0.0, 0.0] as Array<Float>;

                BackgroundAnimationLogic.updateStars(buffer, w, h, false);

                Test.assertMessage(
                    buffer[2] > 0.0,
                    "Star phase should be initialized."
                );

                var initialPhase = buffer[2];

                BackgroundAnimationLogic.updateStars(buffer, w, h, true);

                Test.assertMessage(
                    buffer[2] != initialPhase,
                    "Star phase should change when animation is ON."
                );

                logger.debug("BackgroundAnimationLogic.updateStars passed.");
                return true;
            }

            (:test)
            function benchmarkBackgroundAnimationLogicUpdate(
                logger as Test.Logger
            ) as Boolean {
                var starBuffer = new [120] as Array<Float>; // 40 stars
                for (var j = 0; j < 120; j++) {
                    starBuffer[j] = 0.0;
                }

                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    BackgroundAnimationLogic.updateStars(
                        starBuffer,
                        240,
                        240,
                        true
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [BackgroundAnimationLogic updateStars]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "BackgroundAnimationLogic update is too slow."
                );
                return true;
            }
        }
    }
}
