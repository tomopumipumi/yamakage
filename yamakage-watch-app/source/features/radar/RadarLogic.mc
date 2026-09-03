import Toybox.Math;
import Toybox.Lang;

module Features {
    module Radar {
        module RadarLogic {
            const MAX_DISTANCE_M = 30000.0;

            function getPolarCoordinates(
                azDeg as Float,
                distanceM as Float,
                cx as Number,
                cy as Number,
                maxRadius as Float
            ) as Array<Number> {
                var d = distanceM;
                if (d <= 0.0 || d > MAX_DISTANCE_M) {
                    d = MAX_DISTANCE_M;
                }

                var r = maxRadius * (d / MAX_DISTANCE_M);
                var rad = ((azDeg - 90.0) * Math.PI) / 180.0;

                var px = cx + (r * Math.cos(rad)).toNumber();
                var py = cy + (r * Math.sin(rad)).toNumber();

                return [px, py] as Array<Number>;
            }

            function getIconCoordinates(
                azDeg as Float,
                cx as Number,
                cy as Number,
                radius as Float,
                offset as Number
            ) as Array<Number> {
                var rad = ((azDeg - 90.0) * Math.PI) / 180.0;
                var r = radius + offset;
                var px = cx + (r * Math.cos(rad)).toNumber();
                var py = cy + (r * Math.sin(rad)).toNumber();
                return [px, py] as Array<Number>;
            }

            function formatDistance(distanceM as Float) as String {
                if (distanceM <= 0.0 || distanceM >= MAX_DISTANCE_M) {
                    return ">30km";
                }
                return (distanceM / 1000.0).format("%.1f") + "km";
            }
        }
    }
}
