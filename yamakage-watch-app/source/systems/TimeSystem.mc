import Toybox.Time;
import Toybox.Lang;
import Toybox.System;

module Systems {
    module TimeSystem {
        function formatUnixTime(unixSec as Long or Number or Null) as String {
            if (unixSec != null && unixSec > 0) {
                var moment = new Time.Moment(unixSec.toNumber());
                var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

                var settings = System.getDeviceSettings();

                var hour = info.hour;
                var amPm = "";

                if (!settings.is24Hour) {
                    if (hour >= 12) {
                        amPm = "p";
                        if (hour > 12) {
                            hour -= 12;
                        }
                    } else {
                        amPm = "a";
                        if (hour == 0) {
                            hour = 12;
                        }
                    }
                }

                return Lang.format("$1$:$2$$3$", [
                    hour.format("%d"),
                    info.min.format("%02d"),
                    amPm
                ]);
            }
            return "--:--";
        }

        function formatUnixDate(unixSec as Long or Number or Null) as String {
            if (unixSec != null && unixSec > 0) {
                var moment = new Time.Moment(unixSec.toNumber());
                var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
                return Lang.format("($1$/$2$)", [
                    info.month.format("%d"),
                    info.day.format("%d")
                ]);
            }
            return "";
        }
    }
}
