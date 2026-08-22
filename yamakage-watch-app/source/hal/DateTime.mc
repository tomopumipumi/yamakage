import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

module Hal {
    module DateTime {
        (:debug)
        function createTargetUnixTime() as Number {
            var dummyDateOptions = {
                :year => 2026,
                :month => 8,
                :day => 23,
                :hour => 0,
                :minute => 0,
                :second => 0
            };
            var moment = Gregorian.moment(dummyDateOptions);
            
            var offset = new Time.Duration(9 * 3600); // 9 = UTC adjustment
            var dummyUnixTime = moment.subtract(offset).value();
            
            return dummyUnixTime;
        }

        (:release)
        function createTargetUnixTime() as Number {
            return Time.now().value();
        }
    }
}
