import Toybox.Lang;
import Shared.Core.Page;

import Features.Main;
import Features.Panorama;
import Features.Radar;
import Features.SkyPlot;
import Features.Details;
import Features.Error;
import Features.Loading;
import Features.Settings;

module Shared {
    module Core {
        module ViewFactory {
            function create(pageId as Number) as Array<Object?>? {
                switch (pageId) {
                    case Page.MAIN:
                        return [new Main.MainView(), new Main.MainDelegate()];
                    case Page.PANORAMA:
                        return [
                            new Panorama.PanoramaView(),
                            new Panorama.PanoramaDelegate()
                        ];
                    case Page.SKYPLOT:
                        return [
                            new SkyPlot.SkyPlotView(),
                            new SkyPlot.SkyPlotDelegate()
                        ];
                    case Page.RADAR:
                        return [
                            new Radar.RadarView(),
                            new Radar.RadarDelegate()
                        ];
                    case Page.DETAILS:
                        return [
                            new Details.DetailsView(),
                            new Details.DetailsDelegate()
                        ];
                    case Page.ERROR:
                        return [
                            new Error.ErrorView(),
                            new Error.ErrorDelegate()
                        ];
                    case Page.LOADING:
                        return [new Loading.LoadingView(), null];
                    case Page.SETTINGS:
                        var view = new Settings.SettingsView();
                        return [view, new Settings.SettingsDelegate(view)];
                }
                return null;
            }
        }
    }
}
