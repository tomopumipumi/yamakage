import Toybox.Application;
import Toybox.Time;
import Toybox.Lang;
import Toybox.Math;
import Systems.Crypt;
import Core.ApiSchema;

(:background)
module Hal {
    var SESSION_ID_KEY = "session_id";
    var SHADOW_DATA_KEY = "shadow_data";
    var LAST_SYNC_ERROR_KEY = "last_sync_error";
    var LAST_SYNC_TIME_KEY = "last_sync_time";

    (:background)
    module LocalStorage {
        function getSessionId() as String {
            var sid = Application.Storage.getValue(SESSION_ID_KEY);
            if (sid == null || !(sid instanceof String)) {
                sid = Crypt.generateRandomSessionId();
                Application.Storage.setValue(SESSION_ID_KEY, sid);
            }
            return sid;
        }

        function getLastSyncTime() as Number? {
            var rawData = Application.Storage.getValue(LAST_SYNC_TIME_KEY);
            return rawData instanceof Number ? rawData : null;
        }

        function setLastSyncTime(timeValue as Number) as Void {
            Application.Storage.setValue(
                LAST_SYNC_TIME_KEY,
                Time.now().value()
            );
        }

        function clearOldData() as Void {
            Application.Storage.deleteValue(LAST_SYNC_TIME_KEY);
            Application.Storage.deleteValue(SHADOW_DATA_KEY);
            Application.Storage.deleteValue(LAST_SYNC_ERROR_KEY);
        }

        (:background)
        module BackgroundStorage {
            function getShadowData() as ApiSchema.ShadowDataPayload? {
                return Application.Storage.getValue(SHADOW_DATA_KEY);
            }
            function setShadowData(
                data as ApiSchema.ShadowDataPayload
            ) as Void {
                Application.Storage.setValue(SHADOW_DATA_KEY, data);
            }

            function getLastSyncError() as ApiSchema.BackgroundError? {
                return Application.Storage.getValue(LAST_SYNC_ERROR_KEY);
            }
            function setLastSyncError(
                data as ApiSchema.BackgroundError?
            ) as Void {
                Application.Storage.setValue(LAST_SYNC_ERROR_KEY, data);
            }
        }
    }
}
