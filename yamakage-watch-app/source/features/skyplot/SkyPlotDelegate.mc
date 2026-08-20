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
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            }
            function onPreviousPage() as Boolean {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                return true;
            }
            function onNextPage() as Boolean {
                MH.Router.push(Page.RADAR, WatchUi.SLIDE_UP);
                return true;
            }
        }
    }
}
