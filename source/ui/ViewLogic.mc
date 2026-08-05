import Toybox.Lang;
import Hal.LocalStorage;
import Hal.LocalStorage.BackgroundStorage;
import Core.DataArena.UiArena;
import Core.ApiSchema.DataIndex;
import Systems.TimeSystem.SyncTimeMetrics;
import Systems.TimeSystem;

module Ui {
    typedef ConnectionLabelSetType as Array<String>;

    module ConnectionLabelSet {
        enum {
            COMMUNICATING,
            UPDATE_FAILED,
            UPDATING,
            NEXT_UPDATE
        }
    }

    module ViewLogic {
        function update(labelSet as ConnectionLabelSetType) as Void {
            var rawData = BackgroundStorage.getShadowData();
            var lastSyncTime = LocalStorage.getLastSyncTime();
            var lastSyncError = BackgroundStorage.getLastSyncError();

            if (lastSyncTime == null) {
                UiArena.syncStatus = labelSet[ConnectionLabelSet.COMMUNICATING];
                return;
            }

            var metrics = TimeSystem.calculateSyncTimeMetrics(lastSyncTime);
            var remainingSeconds = metrics[SyncTimeMetrics.REMAINING_SECONDS];
            var elapsedMin = metrics[SyncTimeMetrics.ELAPSED_MINUTES];

            if (rawData != null) {
                UiArena.sunsetTime = TimeSystem.formatUnixTime(
                    rawData[DataIndex.IDX_SUNSET_TIME]
                );
                UiArena.sunriseTime = TimeSystem.formatUnixTime(
                    rawData[DataIndex.IDX_SUNRISE_TIME]
                );

                var sunsetMins = rawData[DataIndex.IDX_MINUTES_TO_SUNSET];
                UiArena.currentSunset =
                    sunsetMins != null
                        ? ((sunsetMins as Number) - elapsedMin).toNumber()
                        : 0;

                var sunriseMins = rawData[DataIndex.IDX_MINUTES_TO_SUNRISE];
                UiArena.currentSunrise =
                    sunriseMins != null
                        ? ((sunriseMins as Number) - elapsedMin).toNumber()
                        : 0;
            }

            if (lastSyncError != null) {
                UiArena.isFailed = true;
                var customMsg = lastSyncError["errorMessage"];
                UiArena.syncStatus =
                    customMsg != null && customMsg instanceof String
                        ? customMsg
                        : labelSet[ConnectionLabelSet.UPDATE_FAILED];
            } else if (remainingSeconds < 0) {
                UiArena.isFailed = false;
                UiArena.syncStatus = labelSet[ConnectionLabelSet.UPDATING];
            } else {
                UiArena.isFailed = false;
                var m = remainingSeconds / 60;
                var s = remainingSeconds % 60;
                UiArena.syncStatus = Lang.format("$1$:$2$", [
                    m,
                    s.format("%02d")
                ]);
            }
        }
    }
}
