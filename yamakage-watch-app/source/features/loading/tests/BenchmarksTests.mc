import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Toybox.Math;

using MonkeyHooks.TestUtils as MHTest;

import Features.Loading.Components.LoadingSun;
import Features.Loading.Components.LoadingMoon;
import Features.Loading.Components.LoadingMountains;

module Features {
    module Loading {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkLoadingRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 500; // Full screen render
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    LoadingRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [LoadingRender Full]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 50.0,
                    "LoadingRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Component Benchmarks
            // ==================================================
            (:test)
            function benchmarkLoadingSunRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    LoadingSun.render(dc, 120, 120, Math.PI);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [LoadingSun]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "LoadingSun rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkLoadingMoonRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    LoadingMoon.render(dc, 120, 120, Math.PI);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [LoadingMoon]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "LoadingMoon rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkLoadingMountainsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    LoadingMountains.render(dc, 240, 240);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [LoadingMountains]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "LoadingMountains rendering is too slow."
                );
                return true;
            }
        }
    }
}
