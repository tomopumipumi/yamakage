import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Math;

import Shared.Core.Enums.TargetMode;
using MonkeyHooks.TestUtils as MHTest;

import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarBeam;
import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarMoon;
import Features.Radar.Components.RadarSonarPulse;
import Features.Radar.Components.RadarSun;

module Features {
    module Radar {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkRadarRenderFull(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 100; // Full screen render
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarRender Full]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 100.0,
                    "RadarRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Individual Component Benchmarks
            // ==================================================

            (:test)
            function benchmarkRadarAreaRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                var iterations = 200; // Complex polygon filling
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarArea.render(dc, profiles, 15, 120, 120, 90.0);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarArea]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "RadarArea rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkRadarBeamRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                var iterations = 200; // Math heavy
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarBeam.render(dc, 45.0, profiles, 15, 120, 120, 90.0);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarBeam]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "RadarBeam rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkRadarGridRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarGrid.render(dc, 120, 120, 90.0, Graphics.FONT_TINY);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarGrid]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 30.0,
                    "RadarGrid rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkRadarMoonRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarMoon.render(dc, paths, 120, 120, 90.0, 0.5, 0.5);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarMoon]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "RadarMoon rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkRadarSunRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarSun.render(dc, paths, 120, 120, 90.0);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarSun]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "RadarSun rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkRadarSonarPulseRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    RadarSonarPulse.render(dc, 120, 120, 90.0, Math.PI);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [RadarSonarPulse]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 10.0,
                    "RadarSonarPulse rendering is too slow."
                );
                return true;
            }
        }
    }
}
