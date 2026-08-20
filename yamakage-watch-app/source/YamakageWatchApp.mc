import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Systems.Crypt;
import Shared.Core.Page;
import Features.Main;
import Features.Panorama;
import Features.SkyPlot;
import Features.Radar;
import Features.Details;
import Features.Error;
import Features.Loading;

using MonkeyHooks as MH;

const SESSION_ID_KEY = "session_id";

class YamakageWatchApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
        MH.Router.initialize(method(:viewFactory));
    }

    function onStart(state as Dictionary?) as Void {
        MH.useStorageString(SESSION_ID_KEY).init(
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
