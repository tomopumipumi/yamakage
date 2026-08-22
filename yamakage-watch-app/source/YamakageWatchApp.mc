import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Systems.Crypt;
import Shared.Core.Page;
import Shared.Core.Consts;
import Shared.Core.Consts.SettingIds;
import Features.Main;
import Features.Panorama;
import Features.SkyPlot;
import Features.Radar;
import Features.Details;
import Features.Error;
import Features.Loading;
import Features.Settings;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;

class YamakageWatchApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        MH.Router.initialize(method(:viewFactory));

        var frStr = MH.useStorageString(SettingIds.FRAME_RATE).init("0").req();
        var frIdx = frStr.toNumber();

        if (frIdx == null || frIdx < 0 || frIdx >= Consts.FRAME_RATES.size()) {
            frIdx = 0;
        }

        var intervalMs = Consts.FRAME_RATES[frIdx][:val] as Number;
        MH.SharedTimer.setInterval(intervalMs);
    }

    function onStart(state as Dictionary?) as Void {
        MH.useStorageString(Consts.SESSION_ID_KEY).init(
            Crypt.generateRandomSessionId()
        );
    }

    function viewFactory(pageId as Number) as Array<Object?>? {
        if (pageId == Page.MAIN) {
            return [new Main.MainView(), new Main.MainDelegate()];
        } else if (pageId == Page.PANORAMA) {
            return [
                new Panorama.PanoramaView(),
                new Panorama.PanoramaDelegate()
            ];
        } else if (pageId == Page.SKYPLOT) {
            return [new SkyPlot.SkyPlotView(), new SkyPlot.SkyPlotDelegate()];
        } else if (pageId == Page.RADAR) {
            return [new Radar.RadarView(), new Radar.RadarDelegate()];
        } else if (pageId == Page.DETAILS) {
            return [new Details.DetailsView(), new Details.DetailsDelegate()];
        } else if (pageId == Page.ERROR) {
            return [new Error.ErrorView(), new Error.ErrorDelegate()];
        } else if (pageId == Page.LOADING) {
            return [new Loading.LoadingView(), null];
        } else if (pageId == Page.SETTINGS) {
            return [
                new Settings.SettingsView(),
                new Settings.SettingsDelegate()
            ];
        }
        return null;
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() {
        return [new Main.MainView(), new Main.MainDelegate()];
    }
}

function getApp() as YamakageWatchApp {
    return Application.getApp() as YamakageWatchApp;
}
