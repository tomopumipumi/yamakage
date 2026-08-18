import Toybox.Lang;
import Toybox.WatchUi;
import Features.Panorama;
import Features.SkyPlot;
import Features.Details;
import Features.Error;

module Shared {
    module Core {
        module Router {
            // Do not include error pages.
            const TOTAL_PAGES = 3;

            module Page {
                enum {
                    PANORAMA = 0,
                    SKYPLOT = 1,
                    DETAILS = 2,
                    ERROR = 3
                }
            }

            function navigateTo(
                pageId as Number,
                transition as WatchUi.SlideType
            ) as Void {
                WatchUi.pushView(
                    _getView(pageId),
                    _getDelegate(pageId),
                    transition
                );
            }

            function switchTo(
                pageId as Number,
                transition as WatchUi.SlideType
            ) as Void {
                WatchUi.switchToView(
                    _getView(pageId),
                    _getDelegate(pageId),
                    transition
                );
            }

            function _getView(pageId as Number) as WatchUi.View {
                if (pageId == Page.PANORAMA) {
                    return new Panorama.PanoramaView();
                } else if (pageId == Page.SKYPLOT) {
                    return new SkyPlot.SkyPlotView();
                } else if (pageId == Page.DETAILS) {
                    return new Details.DetailsView();
                } else if (pageId == Page.ERROR) {
                    return new Error.ErrorView();
                }
                return new Panorama.PanoramaView();
            }

            function _getDelegate(
                pageId as Number
            ) as WatchUi.BehaviorDelegate {
                if (pageId == Page.PANORAMA) {
                    return new Panorama.PanoramaDelegate();
                } else if (pageId == Page.SKYPLOT) {
                    return new SkyPlot.SkyPlotDelegate();
                } else if (pageId == Page.DETAILS) {
                    return new Details.DetailsDelegate();
                } else if (pageId == Page.ERROR) {
                    return new Error.ErrorDelegate();
                }
                return new Panorama.PanoramaDelegate();
            }
        }
    }
}
