import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Hal.Sensor.LocationSensor;
import Hal.Sensor.LocationSensor.LatLon;
import Network.ApiClient;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Page;

using MonkeyHooks as MH;
using MonkeyHooks.Touchable as MHTouchable;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.LoadingUiArena as loadA;
using Core.CustomContext as mycx;

module Features {
    module Main {
        class MainDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onMenu() as Boolean {
                MH.Router.switchTo(Page.SETTINGS, WatchUi.SLIDE_UP);
                return true;
            }

            function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
                if (keyEvent.getKey() == WatchUi.KEY_ENTER) {
                    _startCalculation();
                    return true;
                }
                return false;
            }

            function onNextPage() as Boolean {
                var modeCx = MH.useNumber(coreA.TARGET_MODE);
                var current = modeCx.init(TargetMode.SUN).req();

                if (current == TargetMode.SUN) {
                    modeCx.set(TargetMode.MOON);
                } else if (current == TargetMode.MOON) {
                    modeCx.set(TargetMode.NONE);
                    MH.Router.switchTo(Page.SETTINGS, WatchUi.SLIDE_UP);
                }
                return true;
            }

            function onPreviousPage() as Boolean {
                var modeCx = MH.useNumber(coreA.TARGET_MODE);
                var current = modeCx.init(TargetMode.SUN).req();

                if (current == TargetMode.SUN) {
                    modeCx.set(TargetMode.NONE);
                    MH.Router.switchTo(Page.SETTINGS, WatchUi.SLIDE_DOWN);
                } else if (current == TargetMode.MOON) {
                    modeCx.set(TargetMode.SUN);
                }
                return true;
            }

            function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
                var isTouch = System.getDeviceSettings().isTouchScreen;
                if (!isTouch) {
                    return false;
                }

                var coords = clickEvent.getCoordinates();
                var x = coords[0];
                var y = coords[1];

                var hitId = MHTouchable.handleTap(x, y);

                if (hitId == null) {
                    return false;
                }

                switch (hitId) {
                    case MAIN_START_BUTTON_KEY:
                        _startCalculation();
                        return true;
                }

                return true;
            }

            private function _startCalculation() as Void {
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

                var mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();

                switch (mode) {
                    case TargetMode.SUN:
                        ApiClient.fetchSunShadowData(
                            pos[LatLon.LATITUDE],
                            pos[LatLon.LONGITUDE],
                            method(:onSunApiCallback)
                        );
                        break;

                    case TargetMode.MOON:
                        ApiClient.fetchMoonShadowData(
                            pos[LatLon.LATITUDE],
                            pos[LatLon.LONGITUDE],
                            method(:onMoonApiCallback)
                        );
                        break;
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
