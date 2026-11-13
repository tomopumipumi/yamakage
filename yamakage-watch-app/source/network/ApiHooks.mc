import Toybox.Lang;

import Network.ApiClient;
import Core.Config;

module Network {
    (:background)
    module ApiHooks {
        (:inline, :force_dce)
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

        (:inline, :force_dce)
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

        (:background, :inline, :force_dce)
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
