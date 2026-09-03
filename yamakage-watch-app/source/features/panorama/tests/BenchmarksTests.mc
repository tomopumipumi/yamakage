import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Toybox.System;
import Shared.Core.Enums.TargetMode;

import Features.Panorama.TestFixture;
using MonkeyHooks.TestUtils as MHTest;

import Features.Panorama.Components.PanoramaBackground;
import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaLabels;
import Features.Panorama.Components.PanoramaMoonEvents;
import Features.Panorama.Components.PanoramaMoonPath;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaSunEvents;
import Features.Panorama.Components.PanoramaSunPath;

module Features {
    module Panorama {
        (:test)
        module BenchmarkTests {
            // ==================================================
            // Full Render Benchmark
            // ==================================================
            (:test)
            function benchmarkPanoramaRender(logger as Test.Logger) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var iterations = 100; // Full screen render including background animation
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaRender.render(dc, props);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [PanoramaRender Full]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 100.0,
                    "PanoramaRender rendering is too slow."
                );
                return true;
            }

            // ==================================================
            // Individual Component Benchmarks
            // ==================================================

            (:test)
            function benchmarkPanoramaBackgroundRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var props = TestFixture.createDummyProps();
                var cloudBuffer =
                    props[PanoramaProps.CLOUD_BUFFER] as Array<Float>;
                var starBuffer =
                    props[PanoramaProps.STAR_BUFFER] as Array<Float>;
                var iterations = 200; // Medium complexity (multiple circles / points)
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    // Alternate between clouds and stars
                    if (i % 2 == 0) {
                        PanoramaBackground.render(dc, 0, cloudBuffer);
                    } else {
                        PanoramaBackground.render(dc, 1, starBuffer);
                    }
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [PanoramaBackground]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "PanoramaBackground rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaGridRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaGrid.render(dc, 240, 240);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [PanoramaGrid]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 20.0,
                    "PanoramaGrid rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaLabelsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var iterations = 500;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaLabels.render(dc, 180.0, 240, 240, 120);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [PanoramaLabels]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 5.0,
                    "PanoramaLabels rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaMountainsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var points = TestFixture.getDummyMountainPoints();
                var iterations = 200; // Simulating multiple polygon and line draws
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaMountains.render(dc, points, 240);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [PanoramaMountains]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "PanoramaMountains rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaSunPathRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 100; // Complex math and path drawing
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaSunPath.render(dc, paths, 180.0, 240, 240, 1.0);
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [PanoramaSunPath]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 30.0,
                    "PanoramaSunPath rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaMoonPathRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 100; // Complex math and path drawing
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaMoonPath.render(
                        dc,
                        paths,
                        180.0,
                        240,
                        240,
                        0.5,
                        0.5,
                        1.0
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [PanoramaMoonPath]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 30.0,
                    "PanoramaMoonPath rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaSunEventsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 200;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaSunEvents.render(
                        dc,
                        paths,
                        180.0,
                        240,
                        240,
                        Graphics.FONT_TINY
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format("Benchmark [PanoramaSunEvents]: $1$ms / call", [
                        msPerFrame.format("%.3f")
                    ])
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "PanoramaSunEvents rendering is too slow."
                );
                return true;
            }

            (:test)
            function benchmarkPanoramaMoonEventsRender(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iterations = 200;
                var start = System.getTimer();

                for (var i = 0; i < iterations; i++) {
                    PanoramaMoonEvents.render(
                        dc,
                        paths,
                        180.0,
                        240,
                        240,
                        Graphics.FONT_TINY
                    );
                }

                var msPerFrame =
                    (System.getTimer() - start).toFloat() / iterations;
                logger.debug(
                    Lang.format(
                        "Benchmark [PanoramaMoonEvents]: $1$ms / call",
                        [msPerFrame.format("%.3f")]
                    )
                );

                Test.assertMessage(
                    msPerFrame < 15.0,
                    "PanoramaMoonEvents rendering is too slow."
                );
                return true;
            }
        }
    }
}
