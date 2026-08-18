import Toybox.Lang;
import Toybox.WatchUi;

module Features {
    module Details {
        class DetailsDelegate extends WatchUi.BehaviorDelegate {
            function initialize() {
                BehaviorDelegate.initialize();
            }

            function onPreviousPage() as Boolean {
                WatchUi.popView(WatchUi.SLIDE_DOWN);
                return true;
            }

            function onBack() as Boolean {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                return true;
            }
        }
    }
}
