import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Math;

using MonkeyHooks.TestUtils as MHTest;

import Shared.Ui.Button;
import Shared.Ui.MoonIcon;
import Shared.Ui.PageIndicator;
import Shared.Ui.SonarPulse;
import Shared.Ui.SunIcon;
import Shared.Ui.TextLabel;
import Shared.Ui.Toggle;
import Shared.Ui.ValueSelector;

module Shared {
    module Ui {
        (:test)
        module BenchmarkTests {
            (:test)
            function benchmarkButtonRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    Button.render(
                        dc,
                        "START",
                        120,
                        120,
                        100,
                        40,
                        Graphics.FONT_SMALL,
                        Graphics.COLOR_BLUE,
                        Graphics.COLOR_WHITE
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [Shared.Ui.Button]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "Button rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMoonIconRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 200; // Complex polygon calculations
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MoonIcon.render(dc, 120, 120, 0.5, 0.5, 20);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [Shared.Ui.MoonIcon]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "MoonIcon rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPageIndicatorRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PageIndicator.render(dc, 5, 2, 240, 240);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [Shared.Ui.PageIndicator]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "PageIndicator rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkSonarPulseRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SonarPulse.render(
                        dc,
                        120,
                        120,
                        Math.PI,
                        Graphics.COLOR_YELLOW
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [Shared.Ui.SonarPulse]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "SonarPulse rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkSunIconRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 200; // Trigonometry operations in a loop
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SunIcon.render(dc, 120, 120);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [Shared.Ui.SunIcon]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "SunIcon rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkTextLabelRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    TextLabel.render(
                        dc,
                        "HELLO WORLD",
                        120,
                        120,
                        Graphics.FONT_MEDIUM
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [Shared.Ui.TextLabel]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "TextLabel rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkToggleRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    Toggle.render(
                        dc,
                        20,
                        100,
                        200,
                        44,
                        "Animations",
                        true,
                        true
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [Shared.Ui.Toggle]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "Toggle rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkValueSelectorRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    ValueSelector.render(
                        dc,
                        20,
                        100,
                        200,
                        44,
                        "Speed",
                        "Normal",
                        true
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [Shared.Ui.ValueSelector]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "ValueSelector rendering is too slow."
                );
                return true;
            }
        }
    }
}
