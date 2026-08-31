import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Page;
import Shared.Ui.PageIndicator;

import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarSun;
import Features.Radar.Components.RadarMoon;
import Features.Radar.Components.RadarBeam;
import Features.Radar.Components.RadarSonarPulse;

module Features {
    module Radar {
        module RadarRender {
            function render(dc as Graphics.Dc, props as Array) as Void {
                var w = props[RadarProps.W] as Number;
                var h = props[RadarProps.H] as Number;
                var hasData = props[RadarProps.HAS_DATA] as Boolean;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                if (!hasData) {
                    return;
                }

                var cx = props[RadarProps.CX] as Number;
                var cy = props[RadarProps.CY] as Number;
                var radius = props[RadarProps.RADIUS] as Float;
                var nFont = props[RadarProps.N_FONT] as Graphics.FontType;

                var mode = props[RadarProps.MODE] as Number;
                var stepDeg = props[RadarProps.STEP_DEG] as Number;
                var profiles =
                    props[RadarProps.PROFILES] as
                    ApiSchema.AzimuthProfilesArray;
                var paths = props[RadarProps.PATHS] as ApiSchema.PathArray;
                var sweepAngle = props[RadarProps.SWEEP_ANGLE] as Float;
                var heading = props[RadarProps.HEADING] as Float?;

                RadarGrid.render(dc, cx, cy, radius, nFont);
                RadarArea.render(dc, profiles, stepDeg, cx, cy, radius);

                switch (mode) {
                    case TargetMode.SUN:
                        RadarSun.render(dc, paths, cx, cy, radius);
                        break;

                    case TargetMode.MOON:
                        var fraction = props[RadarProps.FRACTION] as Float;
                        var phase = props[RadarProps.PHASE] as Float;
                        RadarMoon.render(
                            dc,
                            paths,
                            cx,
                            cy,
                            radius,
                            fraction,
                            phase
                        );
                        break;
                }

                if (heading != null) {
                    RadarBeam.render(
                        dc,
                        heading,
                        profiles,
                        stepDeg,
                        cx,
                        cy,
                        radius
                    );
                }

                RadarSonarPulse.render(dc, cx, cy, radius, sweepAngle);

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.RADAR,
                    w,
                    h
                );
            }
        }
    }
}
