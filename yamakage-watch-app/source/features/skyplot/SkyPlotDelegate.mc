import Toybox.Lang;
import Toybox.WatchUi;
import Shared.Core.Page;

using MonkeyHooks as MH;

module Features {
    module SkyPlot {
        class SkyPlotDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }
            function onBack() as Boolean {
                MH.Router.pop(WatchUi.SLIDE_RIGHT);
                return true;
            }
            function onPreviousPage() as Boolean {
                MH.Router.switchTo(Page.PANORAMA, WatchUi.SLIDE_DOWN);
                return true;
            }
            function onNextPage() as Boolean {
                MH.Router.switchTo(Page.RADAR, WatchUi.SLIDE_UP);
                return true;
            }
        }
    }
}
