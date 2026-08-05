import Toybox.Position;
import Toybox.Lang;
import Toybox.System;

(:background)
module Hal {
    (:background)
    module Device {
        function getPosition() as Location? {
            return Position.getInfo().position;
        }
    }
}
