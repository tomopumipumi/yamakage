import Toybox.Lang;
import Hal.Device;

typedef LatLon as [Float, Float];

(:background)
module Systems {
    (:background)
    module LatLonSystem {
        function getLatLon() as LatLon? {
            var position = Device.getPosition();

            if (position == null) {
                return null;
            }

            var doubleLatLon = position.toDegrees();
            return [doubleLatLon[0].toFloat(), doubleLatLon[1].toFloat()];
        }
    }
}
