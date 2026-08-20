import Toybox.Lang;
import Toybox.Graphics;
import Hal.Sensor.LocationSensor;

module Features {
    module Main {
        module Components {
            module MainGpsStatus {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    y as Number
                ) as Void {
                    var gpsText = LocationSensor.getGpsStatusString();
                    var gpsColor = LocationSensor.getGpsStatusColor();

                    dc.setColor(gpsColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        cx,
                        y,
                        Graphics.FONT_XTINY,
                        gpsText,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
