import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

module Hal {
    module DateTime {
        (:debug)
        function createTargetUnixTime() as Number {
            var dummyDateOptions = {
                :year => 2026,
                :month => 7,
                :day => 15,
                :hour => 22,
                :minute => 0,
                :second => 0
            };
            dummyDateOptions[:hour] -= 9; // UTC adjustment
            var dummyUnixTime = Gregorian.moment(dummyDateOptions).value();
            return dummyUnixTime;
        }

        (:release)
        function createTargetUnixTime() as Number {
            return Time.now().value();
        }
    }
}
