import Toybox.Lang;
import Toybox.WatchUi;

module Features {
    module Error {
        class ErrorDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onBack() as Boolean {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            }
        }
    }
}
