import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Hal.Sensor.LocationSensor;
import Hal.Sensor.LocationSensor.LatLon;
import Network.ApiClient;
import Core.ApiSchema;
import Features.Loading;
import Shared.Core.Page;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.LoadingUiArena as loadA;
using Core.CustomContext as mycx;

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
                var errCx = MH.useString(coreA.LAST_ERROR);

                if (!System.getDeviceSettings().phoneConnected) {
                    errCx.set("Phone Disconnected");
                    MH.Router.push(Page.ERROR, WatchUi.SLIDE_LEFT);
                    return;
                }

                var pos = LocationSensor.getPosition();
                if (pos == null) {
                    return;
                }

                errCx.set(null);

                MH.useString(loadA.MSG_TEXT).set("Calculation...");
                MH.Router.push(Page.LOADING, WatchUi.SLIDE_LEFT);

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
                var shadowCx = mycx.usePayload(coreA.CURRENT_SHADOW_DATA);
                var errCx = MH.useString(coreA.LAST_ERROR);

                if (responseCode == 200 && data != null && data["d"] != null) {
                    errCx.set(null);
                    shadowCx.set(data["d"]);
                    MH.Router.switchTo(Page.PANORAMA, WatchUi.SLIDE_LEFT);
                } else {
                    var userMsg = "API Error: " + responseCode;
                    if (
                        responseCode ==
                            Communications.BLE_CONNECTION_UNAVAILABLE ||
                        responseCode == Communications.BLE_HOST_TIMEOUT
                    ) {
                        userMsg = "Bluetooth Offline";
                    } else if (
                        responseCode == Communications.NETWORK_REQUEST_TIMED_OUT
                    ) {
                        userMsg = "Network Timeout";
                    } else if (
                        responseCode ==
                        Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE
                    ) {
                        userMsg = "Invalid Response";
                    } else if (responseCode == 401 || responseCode == 403) {
                        userMsg = "Auth Error";
                    } else if (responseCode == 404) {
                        userMsg = "Server Not Found";
                    } else if (responseCode >= 500) {
                        userMsg = "Server Error";
                    }

                    shadowCx.set(null);
                    errCx.set(userMsg);

                    MH.Router.switchTo(Page.ERROR, WatchUi.SLIDE_LEFT);
                }
            }
        }
    }
}
