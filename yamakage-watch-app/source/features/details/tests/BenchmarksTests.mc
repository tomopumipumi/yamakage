import Toybox.Lang;
import Toybox.Test;
import Toybox.System;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;
import Shared.Icons;

import Features.Details.Components.DetailsRow;
import Features.Details.Components.DetailsMoonRow;
import Features.Details.Components.DetailsSeparators;

import Features.Details.TestFixture;
using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Details {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkDetailsRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 200; // Text rendering test
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    DetailsRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [DetailsRender Full]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 50.0,
                    "DetailsRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Component Benchmarks
            // ==================================================
            (:test)
            function benchmarkDetailsRowRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var layoutCtx = TestFixture.createDummyLayoutCtx();
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    DetailsRow.render(
                        dc,
                        60,
                        "SUNRISE",
                        "06:30",
                        Graphics.COLOR_YELLOW,
                        Icons.ICON_SUNRISE,
                        layoutCtx
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [DetailsRow]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 20.0,
                    "DetailsRow rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkDetailsMoonRowRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var layoutCtx = TestFixture.createDummyLayoutCtx();
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    DetailsMoonRow.render(
                        dc,
                        180,
                        "ILLUM",
                        "85.4%",
                        Graphics.COLOR_BLUE,
                        0.854,
                        0.5,
                        layoutCtx
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [DetailsMoonRow]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "DetailsMoonRow rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkDetailsSeparatorsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    DetailsSeparators.render(dc, 240, 240, 4);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [DetailsSeparators]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "DetailsSeparators rendering is too slow."
                );
                return true;
            }
        }
    }
}
