import Toybox.Lang;
import Toybox.Background;
import Toybox.System;
import Toybox.Position;

import Network.ApiHooks;
import Hal.Complication.V1.Status;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {
    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var info = Position.getInfo();

        var latLon =
            info != null &&
            info.position != null &&
            info.accuracy > Position.QUALITY_NOT_AVAILABLE
                ? info.position.toDegrees()
                : null;

        if (latLon == null) {
            Background.exit(Status.NO_GPS);
            return;
        }

        ApiHooks.fetchComplicationData(
            latLon[0].toFloat(),
            latLon[1].toFloat(),
            method(:onBackgroundResponse)
        );
    }

    function onBackgroundResponse(
        responseCode as Number,
        data as Dictionary?
    ) as Void {
        var compData;

        if (responseCode < 0) {
            compData = Status.NETWORK_ERROR;
            Background.exit(compData);
            return;
        }

        if (responseCode >= 400 && responseCode < 600) {
            compData = Status.SERVER_ERROR;
            Background.exit(compData);
            return;
        }

        compData =
            responseCode == 200 && data != null && data.hasKey("d")
                ? data["d"]
                : Status.UNKNOWN_ERROR;
        Background.exit(compData);
    }
}
