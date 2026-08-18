import Toybox.Lang;
import Toybox.WatchUi;
import Shared.Core.Router;

module Features {
    module Panorama {
        class PanoramaDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onBack() as Boolean {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            }

            function onNextPage() as Boolean {
                Router.navigateTo(Router.Page.SKYPLOT, WatchUi.SLIDE_UP);
                return true;
            }
        }
    }
}
