import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Hal.Sensor.LocationSensor;
import Hal.Sensor.LocationSensor.LatLon;
import Network.ApiClient;
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

            function onNextPage() as Boolean {
                return toggleMode();
            }
            function onPreviousPage() as Boolean {
                return toggleMode();
            }

            function toggleMode() as Boolean {
                var modeCx = MH.useNumber(coreA.TARGET_MODE);
                var current = modeCx.init(0).req();
                modeCx.set(current == 0 ? 1 : 0);
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

                var mode = MH.useNumber(coreA.TARGET_MODE).init(0).req();

                if (mode == 0) {
                    ApiClient.fetchSunShadowData(
                        pos[LatLon.LATITUDE],
                        pos[LatLon.LONGITUDE],
                        method(:onSunApiCallback)
                    );
                } else {
                    ApiClient.fetchMoonShadowData(
                        pos[LatLon.LATITUDE],
                        pos[LatLon.LONGITUDE],
                        method(:onMoonApiCallback)
                    );
                }
            }

            function onSunApiCallback(
                responseCode as Number,
                data as Dictionary?
            ) as Void {
                var shadowCx = mycx.useSunPayload(coreA.SUN_SHADOW_DATA);
                handleApiResponse(responseCode, data, shadowCx);
            }

            function onMoonApiCallback(
                responseCode as Number,
                data as Dictionary?
            ) as Void {
                var shadowCx = mycx.useMoonPayload(coreA.MOON_SHADOW_DATA);
                handleApiResponse(responseCode, data, shadowCx);
            }

            private function handleApiResponse(
                responseCode as Number,
                data as Dictionary?,
                shadowCx
            ) as Void {
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
