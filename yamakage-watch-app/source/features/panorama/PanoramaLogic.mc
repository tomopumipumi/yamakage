import Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;

module Features {
    module Panorama {
        module PanoramaLogic {
            function getPanoramaPoints(
                profiles as ApiSchema.AzimuthProfilesArray,
                stepDeg as Number,
                heading as Float,
                width as Number,
                height as Number
            ) as Array<Array<Number> > {
                var points = [] as Array<Array<Number> >;
                var fov = 90.0;

                for (var i = 0; i < profiles.size(); i++) {
                    var item = profiles[i];
                    if (!(item instanceof Array) || item.size() < 1) {
                        continue;
                    }

                    var az = (i * stepDeg).toFloat();
                    var el =
                        item[0] instanceof Number || item[0] instanceof Float
                            ? item[0].toFloat()
                            : 0.0;
                    if (el > 90.0 || el < -90.0) {
                        el = 0.0;
                    }

                    var diff = az - heading;
                    while (diff > 180.0) {
                        diff -= 360;
                    }
                    while (diff < -180.0) {
                        diff += 360;
                    }

                    if (diff >= -fov / 2 && diff <= fov / 2) {
                        var px = (((diff + fov / 2) * width) / fov).toNumber();
                        var padding = (height * 0.2).toNumber();
                        var py =
                            height -
                            padding -
                            ((el / 90.0) * (height - padding * 2)).toNumber();

                        points.add([px, py]);
                    }
                }

                var size = points.size();
                for (var i = 0; i < size; i++) {
                    for (var j = i + 1; j < size; j++) {
                        if (points[i][0] > points[j][0]) {
                            var temp = points[i];
                            points[i] = points[j];
                            points[j] = temp;
                        }
                    }
                }

                return points;
            }

            function getSunPathPoints(
                sunPaths as ApiSchema.SunPathArray,
                heading as Float,
                width as Number,
                height as Number
            ) as Array<Array<Number> > {
                var points = [] as Array<Array<Number> >;
                var fov = 90.0;

                for (var i = 0; i < sunPaths.size(); i++) {
                    var sp = sunPaths[i] as ApiSchema.SunPathPointTuple;
                    var az = sp[ApiSchema.SunPathIndex.AZIMUTH].toFloat();
                    var el = sp[ApiSchema.SunPathIndex.ALTITUDE].toFloat();

                    if (el < 0) {
                        continue;
                    }

                    var diff = az - heading;
                    while (diff > 180.0) {
                        diff -= 360;
                    }
                    while (diff < -180.0) {
                        diff += 360;
                    }

                    if (diff >= -fov / 2 && diff <= fov / 2) {
                        var px = (((diff + fov / 2) * width) / fov).toNumber();
                        var py = getYFromElevation(el, height);
                        points.add([px, py]);
                    }
                }
                return points;
            }

            function getLabelXPos(
                azDeg as Float,
                heading as Float,
                width as Number
            ) as Number? {
                var fov = 90.0;
                var diff = azDeg - heading;
                while (diff > 180) {
                    diff -= 360;
                }
                while (diff < -180) {
                    diff += 360;
                }

                if (diff >= -fov / 2 && diff <= fov / 2) {
                    return (((diff + fov / 2) * width) / fov).toNumber();
                }
                return null;
            }

            function getYFromElevation(
                elDeg as Float,
                height as Number
            ) as Number {
                var padding = (height * 0.2).toNumber();
                return (
                    height -
                    padding -
                    ((elDeg / 90.0) * (height - padding * 2)).toNumber()
                );
            }
        }
    }
}
