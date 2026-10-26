import Toybox.Communications;
import Toybox.Lang;
import Toybox.Application.Storage;
import Core.Config;
import Hal.DateTime;
import Systems.Crypt;
import Shared.Core.Consts;

using MonkeyHooks as MH;

(:background)
module Network {
    (:background)
    module ApiClient {
        (:background)
        class ShadowDataRequest {
            private var _lat as Float;
            private var _lng as Float;
            private var _endpoint as String;
            private var _callback as
                (Method(responseCode as Number, data as Dictionary?) as Void);

            private var _maxRetries as Number = 2;
            private var _currentRetry as Number = 0;

            function initialize(
                lat as Float,
                lng as Float,
                endpoint as String,
                callback as
                    (Method
                        (responseCode as Number, data as Dictionary?) as Void
                    )
            ) {
                _lat = lat;
                _lng = lng;
                _endpoint = endpoint;
                _callback = callback;
            }

            function execute() as Void {
                var url = Config.API_BASE_URL + _endpoint;
                var sessionId =
                    Storage.getValue(Consts.SESSION_ID_KEY) as String?;
                if (sessionId == null) {
                    sessionId = Crypt.generateRandomSessionId();
                    Storage.setValue(Consts.SESSION_ID_KEY, sessionId);
                }

                var params = {
                    "lat" => _lat,
                    "lng" => _lng,
                    "time" => DateTime.createTargetUnixTime() * 1000l
                };

                var options = {
                    :method => Communications.HTTP_REQUEST_METHOD_POST,
                    :headers => {
                        "Authorization" => Lang.format("Bearer $1$", [
                            Config.API_KEY
                        ]),
                        "X-Session-Id" => sessionId,
                        "Content-Type"
                        =>
                        Communications.REQUEST_CONTENT_TYPE_JSON
                    },
                    :responseType
                    =>
                    Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
                };

                Communications.makeWebRequest(
                    url,
                    params,
                    options,
                    method(:onResponse)
                );
            }

            function onResponse(
                responseCode as Number,
                data as Dictionary?
            ) as Void {
                var isSuccess = responseCode == 200;
                var isClientError = responseCode >= 400 && responseCode < 500;

                if (
                    isSuccess ||
                    isClientError ||
                    _currentRetry >= _maxRetries
                ) {
                    _callback.invoke(responseCode, data);
                } else {
                    _currentRetry++;
                    execute();
                }
            }
        }

        typedef CallbackMethod as
            (Method(responseCode as Number, data as Dictionary?) as Void);
    }
}
