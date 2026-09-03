import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.System;

using MonkeyHooks as MH;
using MonkeyHooks.TestUtils as MHTest;

import Shared.Core.Enums.TargetMode;
import Shared.Ui.BackgroundAnimation;

module Shared {
    module Logic {
        (:test)
        module BackgroundAnimationTests {
            (:test)
            function testBackgroundAnimationRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var cloudBuffer = [10.0, 10.0, 1.0, 5.0] as Array<Float>;
                var starBuffer = [50.0, 50.0, Math.PI] as Array<Float>;

                try {
                    BackgroundAnimation.render(dc, TargetMode.SUN, cloudBuffer);
                    BackgroundAnimation.render(dc, TargetMode.MOON, starBuffer);
                    logger.debug(
                        "BackgroundAnimation.render executed successfully."
                    );
                } catch (e) {
                    logger.error(
                        "BackgroundAnimation.render crashed: " +
                            e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function benchmarkBackgroundAnimationRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var cloudBuffer = new [40] as Array<Float>; // 10 clouds
                for (var j = 0; j < 40; j++) {
                    cloudBuffer[j] = 10.0;
                }

                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    BackgroundAnimation.render(dc, TargetMode.SUN, cloudBuffer);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [BackgroundAnimation]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 40.0,
                    "BackgroundAnimation rendering is too slow."
                );
                return true;
            }
        }
    }
}
