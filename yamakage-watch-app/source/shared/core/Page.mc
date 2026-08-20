import Toybox.Lang;
import Toybox.WatchUi;
import Features.Panorama;
import Features.SkyPlot;
import Features.Details;
import Features.Error;
import Features.Radar;

module Shared {
    module Core {
        const TOTAL_PAGES = 4;

        module Page {
            enum {
                PANORAMA = 0,
                SKYPLOT,
                RADAR,
                DETAILS,

                MAIN = 100,
                LOADING,
                ERROR
            }
        }
    }
}
