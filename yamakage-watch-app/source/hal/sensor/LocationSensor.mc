import Toybox.Position;
import Toybox.Lang;
import Toybox.Graphics;

module Hal {
    module Sensor {
        module LocationSensor {
            module LatLon {
                enum {
                    LATITUDE,
                    LONGITUDE
                }
            }

            function getPosition() as Array<Float>? {
                var info = Position.getInfo();

                if (
                    info != null &&
                    info.position != null &&
                    info.accuracy > Position.QUALITY_NOT_AVAILABLE
                ) {
                    var doubleLatLon = info.position.toDegrees();

                    var lat = doubleLatLon[LatLon.LATITUDE].toFloat();
                    var lon = doubleLatLon[LatLon.LONGITUDE].toFloat();

                    return lat >= -89.999 &&
                        lat <= 89.999 &&
                        lon >= -180.0 &&
                        lon <= 180.0
                        ? [lat, lon]
                        : null;
                }

                return null;
            }

            function getGpsStatusString() as String {
                var info = Position.getInfo();
                if (info == null || info.accuracy == null) {
                    return "GPS: off";
                }

                switch (info.accuracy) {
                    case Position.QUALITY_GOOD:
                        return "GPS: Good";
                    case Position.QUALITY_USABLE:
                        return "GPS: Usable";
                    case Position.QUALITY_POOR:
                        return "GPS: Poor";
                    case Position.QUALITY_LAST_KNOWN:
                        return "GPS: Last Known";
                    case Position.QUALITY_NOT_AVAILABLE:
                    default:
                        return "GPS: Searching...";
                }
            }

            function getGpsStatusColor() as Graphics.ColorType {
                var info = Position.getInfo();
                if (info == null || info.accuracy == null) {
                    return Graphics.COLOR_DK_GRAY;
                }

                switch (info.accuracy) {
                    case Position.QUALITY_GOOD:
                    case Position.QUALITY_USABLE:
                        return Graphics.COLOR_GREEN;
                    case Position.QUALITY_POOR:
                        return Graphics.COLOR_ORANGE;
                    default:
                        return Graphics.COLOR_RED;
                }
            }
        }
    }
}
