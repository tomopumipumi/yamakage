import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;

import Features.SkyPlot.Components.SkyPlotGrid;
import Features.SkyPlot.Components.AzimuthChart;
import Features.SkyPlot.Components.SunPathChart;
import Features.SkyPlot.Components.MoonPathChart;
import Features.SkyPlot.Components.SkyPlotSunEvents;
import Features.SkyPlot.Components.SkyPlotMoonEvents;
import Features.SkyPlot.Components.HeadingMarker;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module SkyPlot {
        (:test)
        module SmokeTests {
            (:test)
            function testSkyPlotGridRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                try {
                    SkyPlotGrid.render(dc, 120, 120, 90.0, Graphics.FONT_TINY);
                    logger.debug("SkyPlotGrid.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "SkyPlotGrid.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testAzimuthChartRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                try {
                    AzimuthChart.render(dc, profiles, 15, 120, 120, 90.0);
                    logger.debug("AzimuthChart.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "AzimuthChart.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testSunPathChartRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                try {
                    SunPathChart.render(dc, paths, 120, 120, 90.0, 1.0);
                    logger.debug("SunPathChart.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "SunPathChart.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testMoonPathChartRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                try {
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
                    logger.debug("MoonPathChart.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "MoonPathChart.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testSkyPlotEventsRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var paths = TestFixture.getDummyPaths();
                var iconFont = Graphics.FONT_TINY;

                try {
                    SkyPlotSunEvents.render(
                        dc,
                        paths,
                        120,
                        120,
                        90.0,
                        iconFont
                    );
                    SkyPlotMoonEvents.render(
                        dc,
                        paths,
                        120,
                        120,
                        90.0,
                        iconFont
                    );
                    logger.debug("SkyPlotEvents.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "SkyPlotEvents.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }

            (:test)
            function testHeadingMarkerRenderDoesNotCrash(
                logger as Test.Logger
            ) as Boolean {
                var dc = MHTest.createDummyDc(240, 240);
                var profiles = TestFixture.getDummyProfiles();
                try {
                    HeadingMarker.render(
                        dc,
                        45.0,
                        profiles,
                        15,
                        120,
                        120,
                        90.0
                    );
                    logger.debug("HeadingMarker.render executed successfully.");
                } catch (e) {
                    logger.error(
                        "HeadingMarker.render crashed: " + e.getErrorMessage()
                    );
                    return false;
                }
                return true;
            }
        }
    }
}
