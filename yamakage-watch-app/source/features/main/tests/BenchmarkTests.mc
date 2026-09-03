import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.System;

import Shared.Core.Enums.TargetMode;
using MonkeyHooks.TestUtils as MHTest;

import Features.Main.Components.MainBackground;
import Features.Main.Components.MainGpsStatus;
import Features.Main.Components.MainSettingsButton;
import Features.Main.Components.MainStartAction;
import Features.Main.Components.MainSunAnimation;
import Features.Main.Components.MainTargetSelector;
import Features.Main.Components.MainTitle;

module Features {
    module Main {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkMainRenderFull(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 100;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MainRender Full]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 100.0,
                    "MainRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Individual Component Benchmarks
            // ==================================================
            (:test)
            function benchmarkMainBackgroundRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainBackground.render(dc, 240, 240);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MainBackground]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "MainBackground rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMainGpsStatusRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainGpsStatus.render(
                        dc,
                        120,
                        24,
                        "GPS: OK",
                        Graphics.COLOR_GREEN
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MainGpsStatus]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "MainGpsStatus rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMainSettingsButtonRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainSettingsButton.render(
                        dc,
                        240,
                        240,
                        60,
                        30,
                        Graphics.FONT_TINY
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [MainSettingsButton]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "MainSettingsButton rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMainStartActionRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainStartAction.render(
                        dc,
                        120,
                        192,
                        100,
                        40,
                        Graphics.FONT_SMALL,
                        true,
                        TargetMode.SUN
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MainStartAction]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "MainStartAction rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMainSunAnimationRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var sparkleBuffer = TestFixture.createSparkleBuffer();
                var iterations = 100; // Complex math and many lines, so fewer iterations
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainSunAnimation.render(
                        dc,
                        0.5,
                        240,
                        240,
                        120,
                        TargetMode.SUN,
                        true,
                        sparkleBuffer
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MainSunAnimation]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 30.0,
                    "MainSunAnimation rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMainTargetSelectorRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainTargetSelector.render(dc, 204, 84, TargetMode.SUN);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [MainTargetSelector]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "MainTargetSelector rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMainTitleRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MainTitle.render(dc, 120, 60, Graphics.FONT_LARGE);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MainTitle]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "MainTitle rendering is too slow."
                );
                return true;
            }
        }
    }
}
