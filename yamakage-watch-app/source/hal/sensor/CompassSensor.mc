import Toybox.Sensor;
import Toybox.Math;
import Toybox.Lang;

module Hal {
    module Sensor {
        module CompassSensor {
            function getHeadingDegrees() as Float? {
                var info = Sensor.getInfo();
                if (info != null && info.heading != null) {
                    var headingDeg =
                        ((info.heading * 180.0) / Math.PI) as Float;
                    return headingDeg < 0 ? headingDeg + 360.0 : headingDeg;
                }
                return null;
            }
        }
    }
}
