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

        if (System.getDeviceSettings().phoneConnected) {
            var lastSyncTime = LocalStorage.getLastSyncTime();
            if (lastSyncTime == null) {
                Background.registerForTemporalEvent(Time.now());
            } else {
                var duration = new Time.Duration(durationMins * 60);
                Background.registerForTemporalEvent(duration);
            }
        } else {
            BackgroundStorage.setLastSyncError({
                "errorCode" => "CANNOT_CONNECT_PHONE",
                "errorMessage" => Strings.getFailConnectPhoneMsg()
            });
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
        BackgroundStorage.setLastSyncError(
            ({
                "errorCode" => "NULL_DATA_RETURNED",
                "errorMessage" => Strings.getFailBackgroundProcessMsg()
            }) as ApiSchema.BackgroundError
        );
    }
}

function getApp() as YamakageApp {
    return Application.getApp() as YamakageApp;
}
