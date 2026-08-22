import Toybox.Lang;

module MonkeyHooks {
    var _watchers as Array<Dictionary>? = null;

    function watch(
        target as Object,
        methodSymbol as Symbol,
        deps as Array<Object>
    ) as Void {
        if (_watchers == null) {
            _watchers = [] as Array<Dictionary>;
        }

        var store = getStore();
        var initialVals = new [deps.size()];
        for (var i = 0; i < deps.size(); i++) {
            initialVals[i] = store.get(deps[i]);
        }

        var found = false;
        for (var i = 0; i < _watchers.size(); i++) {
            var w = _watchers[i] as Dictionary;
            if (w[:weakRef].get() == target && w[:symbol] == methodSymbol) {
                w[:deps] = deps;
                w[:lastVals] = initialVals;
                found = true;
                break;
            }
        }

        if (!found) {
            _watchers.add({
                :weakRef => target.weak(),
                :symbol => methodSymbol,
                :deps => deps,
                :lastVals => initialVals
            });
        }
    }

    function unwatch(target as Object, methodSymbol as Symbol) as Void {
        if (_watchers != null) {
            for (var i = _watchers.size() - 1; i >= 0; i--) {
                var w = _watchers[i] as Dictionary;
                var obj = w[:weakRef].get();
                if (
                    obj == null ||
                    (obj == target && w[:symbol] == methodSymbol)
                ) {
                    _watchers.remove(w);
                }
            }
        }
    }

    function _triggerWatchers() as Void {
        if (_watchers != null) {
            var store = getStore();
            for (var i = _watchers.size() - 1; i >= 0; i--) {
                var w = _watchers[i] as Dictionary;
                var obj = w[:weakRef].get();
                if (obj != null) {
                    if (obj has w[:symbol]) {
                        var deps = w[:deps] as Array<Object>;
                        var lastVals = w[:lastVals] as Array;
                        var currentVals = new [deps.size()];
                        var changed = false;

                        for (var j = 0; j < deps.size(); j++) {
                            currentVals[j] = store.get(deps[j]);
                            if (currentVals[j] != lastVals[j]) {
                                changed = true;
                            }
                        }

                        if (changed) {
                            w[:lastVals] = currentVals;
                            obj.method(w[:symbol]).invoke(currentVals);
                        }
                    }
                } else {
                    _watchers.remove(w);
                }
            }
        }
    }
}
