import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Complications;
import Systems.Crypt;
import Shared.Core.Page;
import Shared.Core.Consts;
import Shared.Core.Consts.SettingIds;
import Shared.Core.ViewFactory;
import Features.Main;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Hal.Complication.V1.Manager as ComplicationManager;

class YamakageWatchApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function _viewFactory(pageId as Number) as Array<Object?>? {
        return ViewFactory.create(pageId);
    }

    function onStart(state as Dictionary?) as Void {}

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() {
        var sessionCx = MH.useStorageString(Consts.SESSION_ID_KEY);
        if (sessionCx.get() == null) {
            sessionCx.set(Crypt.generateRandomSessionId());
        }

        MH.Router.initialize(method(:_viewFactory));

        var frIdx = MH.useStorageNumber(SettingIds.FRAME_RATE).init(0).req();

        if (frIdx < 0 || frIdx >= Consts.FRAME_RATES.size()) {
            frIdx = 0;
        }

        var intervalMs = Consts.FRAME_RATES[frIdx][:val] as Number;
        MH.SharedTimer.setInterval(intervalMs);
        if (System has :ServiceDelegate && Toybox has :Complications) {
            var intervalIdx = MH.useStorageNumber(SettingIds.BG_UPDATE_INTERVAL)
                .init(0)
                .req();
            if (
                intervalIdx >= 0 &&
                intervalIdx < Consts.BG_UPDATE_OPTIONS.size()
            ) {
                var intervalSec =
                    Consts.BG_UPDATE_OPTIONS[intervalIdx][:val] as Number;
                if (intervalSec > 0) {
                    Background.registerForTemporalEvent(
                        new Time.Duration(intervalSec)
                    );
                }
            }
        }
        return [new Main.MainView(), new Main.MainDelegate()];
    }

    function getServiceDelegate() as [System.ServiceDelegate] {
        return [new BackgroundServiceDelegate()];
    }

    function onBackgroundData(data as Application.PersistableType) as Void {
        if (!(Toybox has :Complications)) {
            return;
        }
        ComplicationManager.update(data);
    }
}

function getApp() as YamakageWatchApp {
    return Application.getApp() as YamakageWatchApp;
}
