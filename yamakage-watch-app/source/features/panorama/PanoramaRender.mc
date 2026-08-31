import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;
import Shared.Core.Page;
import Shared.Core.Enums.TargetMode;
import Shared.Ui.BackgroundAnimation;
import Shared.Ui.PageIndicator;

import Features.Panorama.PanoramaLogic;
import Features.Panorama.Components.PanoramaGrid;
import Features.Panorama.Components.PanoramaSunPath;
import Features.Panorama.Components.PanoramaMoonPath;
import Features.Panorama.Components.PanoramaMountains;
import Features.Panorama.Components.PanoramaSunEvents;
import Features.Panorama.Components.PanoramaMoonEvents;
import Features.Panorama.Components.PanoramaLabels;
import Features.Panorama.Components.PanoramaBackground;

module Features {
    module Panorama {
        module PanoramaRender {
            function render(dc as Graphics.Dc, props as Array) as Void {
                var w = props[PanoramaProps.W] as Number;
                var h = props[PanoramaProps.H] as Number;
                var cx = props[PanoramaProps.CX] as Number;

                var mode = props[PanoramaProps.MODE] as Number;
                var cloudBuffer = props[PanoramaProps.CLOUD_BUFFER] as Array?;
                var starBuffer = props[PanoramaProps.STAR_BUFFER] as Array?;
                var hasData = props[PanoramaProps.HAS_DATA] as Boolean;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                var activeBuffer =
                    mode == TargetMode.SUN ? cloudBuffer : starBuffer;
                BackgroundAnimation.render(dc, mode, activeBuffer);

                if (!hasData) {
                    return;
                }

                var heading = props[PanoramaProps.HEADING] as Float;
                var paths = props[PanoramaProps.PATHS] as ApiSchema.PathArray;
                var pulsePhase = props[PanoramaProps.PULSE_PHASE] as Float;
                var iconFont =
                    props[PanoramaProps.ICON_FONT] as Graphics.FontType;

                PanoramaGrid.render(dc, w, h);

                switch (mode) {
                    case TargetMode.SUN:
                        PanoramaSunPath.render(
                            dc,
                            paths,
                            heading,
                            w,
                            h,
                            pulsePhase
                        );
                        break;

                    case TargetMode.MOON:
                        var fraction = props[PanoramaProps.FRACTION] as Float;
                        var phase = props[PanoramaProps.PHASE] as Float;
                        PanoramaMoonPath.render(
                            dc,
                            paths,
                            heading,
                            w,
                            h,
                            fraction,
                            phase,
                            pulsePhase
                        );
                        break;
                }

                var mountainPoints =
                    props[PanoramaProps.MOUNTAIN_POINTS] as
                    Array<Array<Number> >;
                PanoramaMountains.render(dc, mountainPoints, h);

                switch (mode) {
                    case TargetMode.SUN:
                        PanoramaSunEvents.render(
                            dc,
                            paths,
                            heading,
                            w,
                            h,
                            iconFont
                        );
                        break;

                    case TargetMode.MOON:
                        PanoramaMoonEvents.render(
                            dc,
                            paths,
                            heading,
                            w,
                            h,
                            iconFont
                        );
                        break;
                }

                PanoramaLabels.render(dc, heading, w, h, cx);

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.PANORAMA,
                    w,
                    h
                );
            }
        }
    }
}
