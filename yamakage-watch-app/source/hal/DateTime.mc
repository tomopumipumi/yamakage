import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

module Hal {
    (:background)
    module DateTime {
        (:debug, :background)
        function createTargetUnixTime() as Number {
            var dummyDateOptions = {
                :year => 2026,
                :month => 8,
                :day => 28,
                :hour => 17,
                :minute => 0,
                :second => 0
            };
            var moment = Gregorian.moment(dummyDateOptions);

            var offset = new Time.Duration(9 * 3600); // 9 = UTC adjustment
            var dummyUnixTime = moment.subtract(offset).value();

            return dummyUnixTime;
        }

        (:release, :background)
        function createTargetUnixTime() as Number {
            return Time.now().value();
        }
    }
}
