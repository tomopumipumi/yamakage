import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Toybox.Math;

using MonkeyHooks.TestUtils as MHTest;

import Features.Error.Components.ErrorIcon;
import Features.Error.Components.ErrorMessage;
import Features.Error.Components.ErrorMountains;

module Features {
    module Error {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkErrorRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 500; // Full screen render (very lightweight for Error view)
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    ErrorRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [ErrorRender Full]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                // Error screen is very simple, should render well under 30.0ms
                Test.assertMessage(
                    msPerFrame < 30.0,
                    "ErrorRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Component Benchmarks
            // ==================================================
            (:test)
            function benchmarkErrorIconRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    ErrorIcon.render(dc, 120, 84, Math.PI);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [ErrorIcon]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "ErrorIcon rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkErrorMessageRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    ErrorMessage.render(dc, 120, 132, 180, "Network Timeout");
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [ErrorMessage]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 25.0,
                    "ErrorMessage rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkErrorMountainsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    ErrorMountains.render(dc, 240, 240);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [ErrorMountains]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "ErrorMountains rendering is too slow."
                );
                return true;
            }
        }
    }
}
