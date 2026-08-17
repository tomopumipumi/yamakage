import Toybox.Time;
import Toybox.Lang;
import Hal.Strings;

module Systems {
    module TimeSystem {
        module SyncTimeMetrics {
            enum {
                ELAPSED_SECONDS,
                REMAINING_SECONDS,
                ELAPSED_MINUTES
            }
        }

        function calculateSyncTimeMetrics(
            lastSyncTime as Number
        ) as Dictionary {
            var now = Time.now().value();
            var elapsedSec = now - lastSyncTime;

            return {
                SyncTimeMetrics.ELAPSED_SECONDS => elapsedSec,
                SyncTimeMetrics.REMAINING_SECONDS => 300 - elapsedSec,
                SyncTimeMetrics.ELAPSED_MINUTES => elapsedSec / 60.0
            };
        }

        function formatUnixTime(
            targetUnix as Long or Number or Null
        ) as String {
            var unixSec =
                targetUnix instanceof Long
                    ? targetUnix.toNumber()
                    : targetUnix instanceof Number
                      ? targetUnix
                      : null;

            if (unixSec != null && unixSec > 0) {
                var moment = new Time.Moment(unixSec);
                var timeInfo = Gregorian.info(moment, Time.FORMAT_SHORT);

                return Lang.format("$1$:$2$", [
                    timeInfo.hour.format("%02d"),
                    timeInfo.min.format("%02d")
                ]);
            }

            return Strings.getTimeDefaultLabel();
        }
    }
}
