import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Core.ArenaConfig;
import Core.Arena.CoreArena;
import Core.ArenaConfig.ArenaType;
import Hal.LocalStorage;
import Features.Main;

class YamakageWatchApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        var sessCx = ArenaConfig.useArena(
            ArenaType.CORE,
            CoreArena.DataType.SESSION_ID
        );
        sessCx.set(LocalStorage.getSessionId());
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() {
        return [new Main.MainView(), new Main.MainDelegate()];
    }
}

function getApp() as YamakageWatchApp {
    return Application.getApp() as YamakageWatchApp;
}
