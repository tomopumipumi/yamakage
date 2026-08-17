import Toybox.Application;
import Toybox.Lang;

(:background)
module Hal {
    (:background)
    module Property {
        function getBackgroundUpdateDurationMins() as Number? {
            var durationMins = Application.Properties.getValue(
                "BackgroundUpdateDurationMins"
            );
            return durationMins instanceof Number ? durationMins : null;
        }
    }
}
