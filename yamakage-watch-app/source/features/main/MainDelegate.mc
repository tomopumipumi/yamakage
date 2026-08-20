import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Hal.Sensor.LocationSensor;
import Hal.Sensor.LocationSensor.LatLon;
import Network.ApiClient;
import Core.ApiSchema;
import Core.ArenaConfig;
import Core.Arena.CoreArena;
import Core.ArenaConfig.ArenaType;
import Features.Loading;
import Shared.Core.Router;

module Features {
    module Main {
        class MainDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onSelect() as Boolean {
                startCalculation();
                return true;
            }

            function onMenu() as Boolean {
                startCalculation();
                return true;
            }

            private function startCalculation() as Void {
                var errCx = ArenaConfig.useArena(
                    ArenaType.CORE,
                    CoreArena.DataType.LAST_ERROR
                );

                if (!System.getDeviceSettings().phoneConnected) {
                    errCx.set("Phone Disconnected");
                    Router.navigateTo(Router.Page.ERROR, WatchUi.SLIDE_LEFT);
                    return;
                }

                var pos = LocationSensor.getPosition();
                if (pos == null) {
                    return;
                }

                errCx.set(null);
                WatchUi.pushView(
                    new Features.Loading.LoadingView("Calculating..."),
                    null,
                    WatchUi.SLIDE_LEFT
                );

                ApiClient.fetchShadowData(
                    pos[LatLon.LATITUDE],
                    pos[LatLon.LONGITUDE],
                    method(:onApiCallback) as ApiClient.CallbackMethod
                );
            }

            function onApiCallback(
                responseCode as Number,
                data as Dictionary?
            ) as Void {
                var shadowCx = ArenaConfig.useArena(
                    ArenaType.CORE,
                    CoreArena.DataType.CURRENT_SHADOW_DATA
                );
                var errorCx = ArenaConfig.useArena(
                    ArenaType.CORE,
                    CoreArena.DataType.LAST_ERROR
                );

                if (responseCode == 200 && data != null && data["d"] != null) {
                    var payload = data["d"] as ApiSchema.ShadowDataPayload;
                    shadowCx.set(payload);

                    Router.switchTo(Router.Page.PANORAMA, WatchUi.SLIDE_LEFT);
                } else {
                    var userMessage = "API Error: " + responseCode;

                    if (
                        responseCode ==
                            Communications.BLE_CONNECTION_UNAVAILABLE ||
                        responseCode == Communications.BLE_HOST_TIMEOUT
                    ) {
                        userMessage = "Bluetooth Offline";
                    } else if (
                        responseCode == Communications.NETWORK_REQUEST_TIMED_OUT
                    ) {
                        userMessage = "Network Timeout";
                    } else if (
                        responseCode ==
                        Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE
                    ) {
                        userMessage = "Invalid Response";
                    } else if (responseCode == 401 || responseCode == 403) {
                        userMessage = "Auth Error";
                    } else if (responseCode == 404) {
                        userMessage = "Server Not Found";
                    } else if (responseCode >= 500) {
                        userMessage = "Server Error";
                    }

                    errorCx.set(userMessage);
                    Router.switchTo(Router.Page.ERROR, WatchUi.SLIDE_LEFT);
                }
            }
        }
    }
}
