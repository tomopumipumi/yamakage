import Toybox.Lang;
import Toybox.WatchUi;
using MonkeyHooks as MH;

module Features {
    module Error {
        class ErrorDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onBack() as Boolean {
                MH.Router.pop(WatchUi.SLIDE_RIGHT);
                return true;
            }
        }
    }
}
