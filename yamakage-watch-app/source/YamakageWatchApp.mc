import Toybox.Application;
import Toybox.Lang;
import Systems.Crypt;
import Shared.Core.Page;
import Shared.Core.Consts;
import Shared.Core.Consts.SettingIds;
import Shared.Core.ViewFactory;
import Features.Main;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

class YamakageWatchApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        MH.Router.initialize(method(:_viewFactory));

        var frIdx = MH.useStorageNumber(SettingIds.FRAME_RATE).init(0).req();

        if (frIdx < 0 || frIdx >= Consts.FRAME_RATES.size()) {
            frIdx = 0;
        }

        var intervalMs = Consts.FRAME_RATES[frIdx][:val] as Number;
        MH.SharedTimer.setInterval(intervalMs);
    }

    function _viewFactory(pageId as Number) as Array<Object?>? {
        return ViewFactory.create(pageId);
    }

    function onStart(state as Dictionary?) as Void {
        var sessionCx = MH.useStorageString(Consts.SESSION_ID_KEY);
        if (sessionCx.get() == null) {
            sessionCx.set(Crypt.generateRandomSessionId());
        }
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() {
        return [new Main.MainView(), new Main.MainDelegate()];
    }
}

function getApp() as YamakageWatchApp {
    return Application.getApp() as YamakageWatchApp;
}
