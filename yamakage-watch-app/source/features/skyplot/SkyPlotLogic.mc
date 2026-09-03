import Toybox.Math;
import Toybox.Lang;

module Features {
    module SkyPlot {
        module SkyPlotLogic {
            function getPolarCoordinates(
                azDeg as Float,
                elDeg as Float,
                cx as Number,
                cy as Number,
                radius as Float
            ) as Array<Number> {
                var clampedEl = elDeg;
                if (clampedEl < 0.0) {
                    clampedEl = 0.0;
                }
                if (clampedEl > 90.0) {
                    clampedEl = 90.0;
                }

                var r = radius * (1.0 - clampedEl / 90.0);

                var rad = ((azDeg - 90.0) * Math.PI) / 180.0;

                var px = cx + (r * Math.cos(rad)).toNumber();
                var py = cy + (r * Math.sin(rad)).toNumber();

                return [px, py] as Array<Number>;
            }
        }
    }
}
