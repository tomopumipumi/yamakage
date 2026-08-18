import Toybox.Communications;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Core.ArenaConfig;
import Core.Config;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;

module Network {
    module ApiClient {
        function fetchShadowData(
            lat as Float,
            lng as Float,
            callback as
                (Method(responseCode as Number, data as Dictionary?) as Void)
        ) as Void {
            var url = Config.API_BASE_URL + Config.SHADOW_ENDPOINT;

            var sessCx = ArenaConfig.useArena(
                ArenaType.CORE,
                CoreArena.DataType.SESSION_ID
            );
            var sessionId = sessCx.get() as String;

            var params = {
                "lat" => lat,
                "lng" => lng,
                "time" => Time.now().value() * 1000l
            };

            var options = {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                    "Authorization" => Lang.format("Bearer $1$", [
                        Config.API_KEY
                    ]),
                    "X-Session-Id" => sessionId,
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };

            Communications.makeWebRequest(url, params, options, callback);
        }
    }
}
