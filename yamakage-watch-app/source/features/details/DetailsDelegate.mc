import Toybox.Lang;
import Toybox.WatchUi;
import Shared.Core.Page;
using MonkeyHooks as MH;

module Features {
    module Details {
        class DetailsDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onPreviousPage() as Boolean {
                MH.Router.pop(WatchUi.SLIDE_DOWN);
                return true;
            }

            function onBack() as Boolean {
                MH.Router.switchTo(Page.MAIN, WatchUi.SLIDE_RIGHT);
                return true;
            }
        }
    }
}
