import Toybox.Lang;
import Toybox.WatchUi;
import Shared.Core.Page;

using MonkeyHooks as MH;

module Features {
    module Radar {
        class RadarDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }
            function onBack() as Boolean {
                MH.Router.switchTo(Page.MAIN, WatchUi.SLIDE_RIGHT);
                return true;
            }
            function onPreviousPage() as Boolean {
                MH.Router.pop(WatchUi.SLIDE_DOWN);
                return true;
            }
            function onNextPage() as Boolean {
                MH.Router.push(Page.DETAILS, WatchUi.SLIDE_UP);
                return true;
            }
        }
    }
}
