import Toybox.Application;
import Toybox.Background;
import Toybox.Communications;
import Toybox.Position;
import Toybox.System;
import Toybox.Lang;
import Toybox.Time.Gregorian;
import Systems.LatLonSystem;
import Core.Config;
import Core.ApiSchema;
import Hal.LocalStorage;
import Hal.Strings;

(:background)
class YamakageBackground extends ServiceDelegate {
    var _targetTime as Number = 0;

    function initialize() {
        ServiceDelegate.initialize();
        _targetTime = createTargetUnixTime();
    }

    (:debug)
    private function createTargetUnixTime() as Number {
        var dummyDateOptions = {
            :year => 2026,
            :month => 7,
            :day => 1,
            :hour => 15,
            :minute => 0,
            :second => 0
        };
        dummyDateOptions[:hour] -= 9; // UTC adjustment
        var dummyUnixTime = Gregorian.moment(dummyDateOptions).value();
        return dummyUnixTime;
    }

    (:release)
    private function createTargetUnixTime() as Number {
        return Time.now().value();
    }

    function onTemporalEvent() as Void {
        if (!System.getDeviceSettings().phoneConnected) {
            Background.exit(
                ({
                    "errorCode" => "DISCONNECTED",
                    "errorMessage" => Strings.getFailConnectPhoneMsg()
                }) as ApiSchema.BackgroundError
            );
            return;
        }

        var latLon = LatLonSystem.getLatLon();

        if (latLon == null) {
            Background.exit({ "error" => "NO_GPS" });
            return;
        }

        var url = Config.API_BASE_URL + Config.SHADOW_ENDPOINT;

        var sessionId = LocalStorage.getSessionId();

        var parameters = {
            "lat" => latLon[0],
            "lng" => latLon[1],
            "time" => _targetTime
        };

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Authorization" => Lang.format("Bearer $1$", [Config.API_KEY]),
                "X-Session-Id" => sessionId,
                "Accept" => "application/json"
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        try {
            Communications.makeWebRequest(
                url,
                parameters,
                options,
                method(:onReceive)
            );
        } catch (e) {
            Background.exit(
                ({
                    "errorCode" => "REQ_EXCEPTION",
                    "errorMessage" => Strings.getUpdateFailedLabel()
                }) as ApiSchema.BackgroundError
            );
        }
    }

    function onReceive(
        responseCode as Number,
        data as Dictionary or String or Null
    ) as Void {
        if (responseCode == 200 && data instanceof Dictionary) {
            var safeArray = data["d"] as ApiSchema.ShadowDataPayload?;

            if (safeArray != null) {
                Background.exit(safeArray);
                return;
            }
        }

        var errMsg =
            responseCode < 0
                ? "BT ERROR " + responseCode.toString()
                : "HTTP " + responseCode.toString();

        Background.exit(
            ({
                "errorCode" => responseCode,
                "errorMessage" => errMsg
            }) as ApiSchema.BackgroundError
        );
    }
}
