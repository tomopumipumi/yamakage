import Toybox.Graphics;
import Toybox.Lang;
import Core.ApiSchema;
import Features.Panorama.PanoramaLogic;

module Features {
    module Panorama {
        module Components {
            module PanoramaMountains {
                function render(
                    dc as Graphics.Dc,
                    profiles as ApiSchema.AzimuthProfilesArray,
                    stepDeg as Number,
                    heading as Float,
                    width as Number,
                    height as Number
                ) as Void {
                    var points = PanoramaLogic.getPanoramaPoints(
                        profiles,
                        stepDeg,
                        heading,
                        width,
                        height
                    );

                    if (points.size() > 1) {
                        dc.setColor(
                            Graphics.COLOR_DK_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        for (var i = 0; i < points.size() - 1; i++) {
                            dc.fillPolygon([
                                [points[i][0], points[i][1]],
                                [points[i + 1][0], points[i + 1][1]],
                                [points[i + 1][0], height],
                                [points[i][0], height]
                            ]);
                        }

                        dc.setColor(
                            Graphics.COLOR_GREEN,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.setPenWidth(3);
                        for (var i = 0; i < points.size() - 1; i++) {
                            dc.drawLine(
                                points[i][0],
                                points[i][1],
                                points[i + 1][0],
                                points[i + 1][1]
                            );
                        }
                    }
                }
            }
        }
    }
}
