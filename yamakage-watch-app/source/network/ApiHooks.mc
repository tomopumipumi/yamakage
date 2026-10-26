import Toybox.Lang;

import Network.ApiClient;
import Core.Config;

module Network {
    (:background)
    module ApiHooks {
        function fetchSunShadowData(
            lat as Float,
            lng as Float,
            callback as CallbackMethod
        ) as Void {
            var request = new ApiClient.ShadowDataRequest(
                lat,
                lng,
                Config.SHADOW_ENDPOINT,
                callback
            );
            request.execute();
        }

        function fetchMoonShadowData(
            lat as Float,
            lng as Float,
            callback as CallbackMethod
        ) as Void {
            var request = new ApiClient.ShadowDataRequest(
                lat,
                lng,
                Config.MOON_SHADOW_ENDPOINT,
                callback
            );
            request.execute();
        }

        (:background)
        function fetchComplicationData(
            lat as Float,
            lng as Float,
            callback as CallbackMethod
        ) as Void {
            var request = new ApiClient.ShadowDataRequest(
                lat,
                lng,
                Config.COMPLICATION_ENDPOINT,
                callback
            );
            request.execute();
        }
    }
}
