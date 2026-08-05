import Toybox.Lang;

(:background)
module Core {
    (:background)
    module ApiSchema {
        typedef ShadowDataPayload as Array<Number or Long>;

        typedef BackgroundError as Dictionary<String, String or Number>;

        module DataIndex {
            enum {
                IDX_MINUTES_TO_SUNSET = 0,
                IDX_SUNSET_TIME = 1,
                IDX_MINUTES_TO_SUNRISE = 2,
                IDX_SUNRISE_TIME = 3
            }
        }
    }
}
