import Toybox.Lang;
import Toybox.WatchUi;

module MonkeyHooks {
    module Router {
        var _viewFactory as Lang.Method? = null;
        var _previewRouteId as Number? = null;

        function initialize(viewFactory as Lang.Method) {
            _viewFactory = viewFactory;
        }

        function push(
            routeId as Number,
            transition as WatchUi.SlideType
        ) as Void {
            if (_viewFactory != null) {
                var views = _viewFactory.invoke(routeId);
                if (
                    views != null &&
                    views instanceof Array &&
                    views.size() >= 1
                ) {
                    var view = views[0] as WatchUi.View;
                    var delegate =
                        views.size() >= 2 && views[1] != null
                            ? views[1] as WatchUi.BehaviorDelegate
                            : null;
                    WatchUi.pushView(view, delegate, transition);
                }
            }
        }

        function pop(transition as WatchUi.SlideType) as Void {
            WatchUi.popView(transition);
        }

        function switchTo(
            routeId as Number,
            transition as WatchUi.SlideType
        ) as Void {
            if (_viewFactory != null) {
                var views = _viewFactory.invoke(routeId as Number);
                if (
                    views != null &&
                    views instanceof Array &&
                    views.size() >= 1
                ) {
                    var view = views[0] as WatchUi.View;
                    var delegate =
                        views.size() >= 2 && views[1] != null
                            ? views[1] as WatchUi.BehaviorDelegate
                            : null;
                    WatchUi.switchToView(view, delegate, transition);
                }
            }
        }
    }
}
