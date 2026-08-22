import Toybox.Time;
import Toybox.Lang;

module Systems {
    module TimeSystem {
        function formatUnixTime(unixSec as Long or Number or Null) as String {
            if (unixSec != null && unixSec > 0) {
                var moment = new Time.Moment(unixSec.toNumber());
                var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
                return Lang.format("$1$:$2$", [
                    info.hour.format("%02d"),
                    info.min.format("%02d")
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
