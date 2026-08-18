import Toybox.Lang;
import Toybox.Application.Storage;
import Systems.Crypt;

module Hal {
    module LocalStorage {
        var SESSION_ID_KEY = "session_id";

        function getSessionId() as String {
            var sid = Storage.getValue(SESSION_ID_KEY);
            if (sid == null || !(sid instanceof String)) {
                sid = Crypt.generateRandomSessionId();
                Storage.setValue(SESSION_ID_KEY, sid);
            }
            return sid;
        }
    }
}
