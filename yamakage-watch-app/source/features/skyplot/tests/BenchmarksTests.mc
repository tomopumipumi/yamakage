import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.System;
import Shared.Core.Enums.TargetMode;
import Shared.Ui.SonarPulse;

using MonkeyHooks.TestUtils as MHTest;

import Features.SkyPlot.Components.AzimuthChart;
import Features.SkyPlot.Components.HeadingMarker;
import Features.SkyPlot.Components.MoonPathChart;
import Features.SkyPlot.Components.SkyPlotGrid;
import Features.SkyPlot.Components.SkyPlotMoonEvents;
import Features.SkyPlot.Components.SkyPlotSunEvents;
import Features.SkyPlot.Components.SunPathChart;

module Features {
    module SkyPlot {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkSkyPlotRenderFull(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 100; // Full screen render is heavy
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SkyPlotRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [SkyPlotRender Full]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 100.0,
                    "SkyPlotRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Individual Component Benchmarks
            // ==================================================

            (:test)
            function benchmarkAzimuthChartRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                var iterations = 200; // Complex polygon filling
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    AzimuthChart.render(dc, profiles, 15, 120, 120, 90.0);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [AzimuthChart]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "AzimuthChart rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkHeadingMarkerRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    HeadingMarker.render(
                        dc,
                        45.0,
                        profiles,
                        15,
                        120,
                        120,
                        90.0
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [HeadingMarker]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "HeadingMarker rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkMoonPathChartRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 200; // Many lines and a complex icon
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    MoonPathChart.render(
                        dc,
                        paths,
                        120,
                        120,
                        90.0,
                        0.5,
                        0.5,
                        1.0
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [MoonPathChart]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "MoonPathChart rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkSkyPlotGridRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SkyPlotGrid.render(dc, 120, 120, 90.0, Graphics.FONT_TINY);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [SkyPlotGrid]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 20.0,
                    "SkyPlotGrid rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkSkyPlotMoonEventsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 200;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SkyPlotMoonEvents.render(
                        dc,
                        paths,
                        120,
                        120,
                        90.0,
                        Graphics.FONT_TINY
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [SkyPlotMoonEvents]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "SkyPlotMoonEvents rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkSkyPlotSunEventsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 200;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SkyPlotSunEvents.render(
                        dc,
                        paths,
                        120,
                        120,
                        90.0,
                        Graphics.FONT_TINY
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [SkyPlotSunEvents]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "SkyPlotSunEvents rendering is too slow."
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
                    SonarPulse.render(dc, 120, 120, 1.0, Graphics.COLOR_YELLOW);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [SonarPulse]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "SonarPulse rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkSunPathChartRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 200; // Many lines and a complex icon
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    SunPathChart.render(dc, paths, 120, 120, 90.0, 1.0);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [SunPathChart]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "SunPathChart rendering is too slow."
                );
                return true;
            }
        }
    }
}
