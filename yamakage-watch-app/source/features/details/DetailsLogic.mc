import Toybox.Lang;
import Toybox.System;
import Core.ApiSchema;
import Systems.TimeSystem;

module Features {
    module Details {
        module DetailsLogic {
            function formatTime(unixSec as Number or Long) as String {
                return TimeSystem.formatUnixTime(unixSec);
            }

            function formatDate(unixSec as Number or Long) as String {
                return TimeSystem.formatUnixDate(unixSec);
            }

            function formatIllumination(fraction as Float) as String {
                return (fraction * 100.0).format("%.1f") + "%";
            }

            (:inline, :force_dce)
            function getElevationString(
                profiles as ApiSchema.AzimuthProfilesArray?,
                stepDeg as Number,
                heading as Float?
            ) as String {
                var result = "--";

                if (heading != null && profiles != null && stepDeg != 0) {
                    var index = (heading / stepDeg).toNumber();

                    if (
                        index >= 0 &&
                        index < profiles.size() &&
                        profiles[index].size() > 0
                    ) {
                        var el =
                            profiles[index][0] instanceof Number ||
                            profiles[index][0] instanceof Float
                                ? profiles[index][0].toFloat()
                                : 0.0;

                        result = el.format("%.1f") + "°";
                    }
                }

                return result;
            }
        }
    }
}
