import Toybox.Lang;
import Toybox.Background;
import Toybox.System;
import Toybox.Position;
import Complication.V1.Consts;
import Complication.V1.Manager;
import Complication.V1.Status;
import Network.ApiHooks;

using Complication.V1.Context as cx;

module Complication {
    module V1 {
        (:background)
        class BackgroundServiceDelegate extends System.ServiceDelegate {
            function initialize(
                RawData_ShortLabelName as String,
                Sunrise_ShortLabelName as String,
                Sunset_ShortLabelName as String
            ) {
                ServiceDelegate.initialize();

                cx.RawData_ShortLabelName =
                    Application.loadResource(
                        Rez.Strings.Comp1_ShortLabelName
                    ) as String;
                cx.Sunrise_ShortLabelName =
                    Application.loadResource(
                        Rez.Strings.Comp2_ShortLabelName
                    ) as String;
                cx.Sunset_ShortLabelName =
                    Application.loadResource(
                        Rez.Strings.Comp3_ShortLabelName
                    ) as String;
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
                    Manager.update(Status.NO_GPS);
                    Background.exit(null);
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
                try {
                    var compData;

                    if (responseCode < 0) {
                        compData = Status.NETWORK_ERROR;
                        Manager.update(compData);
                        return;
                    }

                    if (responseCode >= 400 && responseCode < 600) {
                        compData = Status.SERVER_ERROR;
                        Manager.update(compData);
                        return;
                    }

                    compData =
                        responseCode == 200 && data != null && data.hasKey("d")
                            ? data["d"]
                            : Status.UNKNOWN_ERROR;

                    Manager.update(compData);
                } finally {
                    Background.exit(null);
                }
            }
        }
    }
}
