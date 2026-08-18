import Toybox.Position;
import Toybox.Lang;

module Hal {
    module Sensor {
        module LocationSensor {
            function getPosition() as Array<Float>? {
                var info = Position.getInfo();

                if (info != null && info.position != null) {
                    var doubleLatLon = info.position.toDegrees();
                    return [
                        doubleLatLon[0].toFloat(),
                        doubleLatLon[1].toFloat()
                    ];
                }

                return null;
            }
        }
    }
}
