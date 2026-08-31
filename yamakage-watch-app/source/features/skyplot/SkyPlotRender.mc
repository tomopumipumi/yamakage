import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;
import Shared.Core.Page;
import Shared.Core.Enums.TargetMode;
import Shared.Icons;
import Shared.Ui.BackgroundAnimation;
import Shared.Ui.PageIndicator;

import Features.SkyPlot.Components.AzimuthChart;
import Features.SkyPlot.Components.HeadingMarker;
import Features.SkyPlot.Components.SkyPlotGrid;
import Features.SkyPlot.Components.SunPathChart;
import Features.SkyPlot.Components.MoonPathChart;
import Features.SkyPlot.Components.SkyPlotSunEvents;
import Features.SkyPlot.Components.SkyPlotMoonEvents;

module Features {
    module SkyPlot {
        module SkyPlotRender {
            function render(dc as Graphics.Dc, props as Array) as Void {
                var w = props[SkyPlotProps.W] as Number;
                var h = props[SkyPlotProps.H] as Number;
                var cx = props[SkyPlotProps.CX] as Number;
                var cy = props[SkyPlotProps.CY] as Number;

                var mode = props[SkyPlotProps.MODE] as Number;
                var cloudBuffer = props[SkyPlotProps.CLOUD_BUFFER] as Array?;
                var starBuffer = props[SkyPlotProps.STAR_BUFFER] as Array?;
                var hasData = props[SkyPlotProps.HAS_DATA] as Boolean;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var activeBuffer =
                    mode == TargetMode.SUN ? cloudBuffer : starBuffer;
                BackgroundAnimation.render(dc, mode, activeBuffer);

                if (!hasData) {
                    return;
                }

                var radius = props[SkyPlotProps.RADIUS] as Float;
                var nFont = props[SkyPlotProps.N_FONT] as Graphics.FontType;
                var iconFont =
                    props[SkyPlotProps.ICON_FONT] as Graphics.FontType;

                var stepDeg = props[SkyPlotProps.STEP_DEG] as Number;
                var profiles =
                    props[SkyPlotProps.PROFILES] as
                    ApiSchema.AzimuthProfilesArray;
                var paths = props[SkyPlotProps.PATHS] as ApiSchema.PathArray;

                var pulsePhase = props[SkyPlotProps.PULSE_PHASE] as Float;
                var heading = props[SkyPlotProps.HEADING] as Float?;

                SkyPlotGrid.render(dc, cx, cy, radius, nFont);
                AzimuthChart.render(dc, profiles, stepDeg, cx, cy, radius);

                switch (mode) {
                    case TargetMode.SUN:
                        SunPathChart.render(
                            dc,
                            paths,
                            cx,
                            cy,
                            radius,
                            pulsePhase
                        );
                        SkyPlotSunEvents.render(
                            dc,
                            paths,
                            cx,
                            cy,
                            radius,
                            iconFont
                        );
                        break;

                    case TargetMode.MOON:
                        var fraction = props[SkyPlotProps.FRACTION] as Float;
                        var phase = props[SkyPlotProps.PHASE] as Float;
                        MoonPathChart.render(
                            dc,
                            paths,
                            cx,
                            cy,
                            radius,
                            fraction,
                            phase,
                            pulsePhase
                        );
                        SkyPlotMoonEvents.render(
                            dc,
                            paths,
                            cx,
                            cy,
                            radius,
                            iconFont
                        );
                        break;
                }

                if (heading != null) {
                    HeadingMarker.render(
                        dc,
                        heading,
                        profiles,
                        stepDeg,
                        cx,
                        cy,
                        radius
                    );
                }

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.SKYPLOT,
                    w,
                    h
                );
            }
        }
    }
}
