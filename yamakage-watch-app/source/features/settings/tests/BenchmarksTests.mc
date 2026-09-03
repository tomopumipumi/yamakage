import Toybox.Lang;
import Toybox.Test;
import Toybox.System;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Settings {
        (:test)
        module BenchmarksTests {
            (:test)
            function benchmarkSettingsRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();

                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SettingsRender.render(dc, props);
                }

                var elapsed = System.getTimer() - start;
                var msPerFrame = elapsed.toFloat() / iterations;

                logger.debug(
                    Lang.format("Benchmark [SettingsRender]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                // Rendering cost threshold (e.g., 2.5ms)
                Test.assertEqualMessage(
                    msPerFrame < 30.5,
                    true,
                    "Rendering of SettingsRender is too slow."
                );

                return true;
            }
        }
    }
}
