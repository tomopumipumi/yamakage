import Toybox.Application;
import Toybox.Time;
import Toybox.Lang;
import Toybox.System;
import Hal.LocalStorage;
import Hal.LocalStorage.BackgroundStorage;
import Hal.Property;
import Hal.Strings;
import Core.ApiSchema;

(:background)
class YamakageApp extends Application.AppBase {
    var MINIMUM_DURATION_MINS = 5;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {}

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() {
        LocalStorage.clearOldData();
        var durationMins = Property.getBackgroundUpdateDurationMins();
        if (durationMins == null || durationMins < MINIMUM_DURATION_MINS) {
            durationMins = MINIMUM_DURATION_MINS;
        }

        try {
            var lastSyncTime = LocalStorage.getLastSyncTime();
            var intervalSeconds = durationMins * 60;

            if (intervalSeconds < 300) {
                intervalSeconds = 300;
            }

            if (lastSyncTime == null) {
                Background.registerForTemporalEvent(
                    new Time.Duration(intervalSeconds)
                );
            } else {
                var now = Time.now().value();
                var elapsed = now - lastSyncTime;

                if (elapsed >= intervalSeconds) {
                    Background.registerForTemporalEvent(
                        new Time.Duration(intervalSeconds)
                    );
                } else {
                    var remaining = intervalSeconds - elapsed;
                    if (remaining < 300) {
                        remaining = 300;
                    }
                    Background.registerForTemporalEvent(
                        new Time.Duration(remaining)
                    );
                }
            }
        } catch (e) {
            System.println(
                "Background registration skipped: " + e.getErrorMessage()
            );
        }

        if (!System.getDeviceSettings().phoneConnected) {
            var errDict = {
                "errorCode" => "DISCONNECTED"
            };
            BackgroundStorage.setLastSyncError(
                errDict as ApiSchema.BackgroundError
            );
        }

        return [new YamakageView()];
    }

    function getServiceDelegate() {
        return [new YamakageBackground()];
    }

    function onSettingsChanged() {
        WatchUi.requestUpdate();
    }

    function onBackgroundData(data) {
        if (data != null) {
            if (data instanceof Array) {
                BackgroundStorage.setShadowData(
                    data as ApiSchema.ShadowDataPayload
                );
                BackgroundStorage.setLastSyncError(null);
            } else if (data instanceof Dictionary) {
                // On Error
                BackgroundStorage.setLastSyncError(
                    data as ApiSchema.BackgroundError
                );
            }
        } else {
            runtimeFallback();
        }
        LocalStorage.setLastSyncTime(Time.now().value());

        var durationMins = Property.getBackgroundUpdateDurationMins();
        if (durationMins == null || durationMins < MINIMUM_DURATION_MINS) {
            durationMins = MINIMUM_DURATION_MINS;
        }
        Background.registerForTemporalEvent(
            new Time.Duration(durationMins * 60)
        );
    }

    private function runtimeFallback() {
        var errDict = {
            "errorCode" => "NULL_DATA_RETURNED"
        };
        BackgroundStorage.setLastSyncError(
            errDict as ApiSchema.BackgroundError
        );
    }
}

function getApp() as YamakageApp {
    return Application.getApp() as YamakageApp;
}
