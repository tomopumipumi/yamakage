import Toybox.Lang;
import Core.Arena.CoreArena;
import Core.Arena.MainUiArena;
import Core.Arena.LoadingUiArena;
import Core.Arena.SkyPlotUiArena;
import Core.Arena.DetailsUiArena;
import Core.Arena.PanoramaUiArena;

module Core {
    module ArenaConfig {
        typedef DataTypeDef as
            CoreArena.DataType.DataTypeDef or
                MainUiArena.DataType.DataTypeDef or
                LoadingUiArena.DataType.DataTypeDef or
                SkyPlotUiArena.DataType.DataTypeDef or
                DetailsUiArena.DataType.DataTypeDef or
                PanoramaUiArena.DataType.DataTypeDef;

        module ArenaType {
            typedef ArenaTypeDef as Number;
            enum {
                CORE,
                MAIN_UI,
                LOADING_UI,
                SKYPLOT_UI,
                DETAILS_UI,
                PANORAMA_UI
            }
        }

        class Context {
            private var _getter as Lang.Method;
            private var _setter as Lang.Method;

            function initialize(getter as Lang.Method, setter as Lang.Method) {
                _getter = getter;
                _setter = setter;
            }

            public function get() {
                return _getter.invoke();
            }

            public function set(arg) as Void {
                _setter.invoke(arg);
                WatchUi.requestUpdate();
            }
        }

        function useArena(
            arenaType as Core.ArenaConfig.ArenaType.ArenaTypeDef,
            dataType as DataTypeDef
        ) as Context? {
            switch (arenaType) {
                case ArenaType.CORE:
                    return CoreArena.useArena(dataType);
                case ArenaType.MAIN_UI:
                    return MainUiArena.useArena(dataType);
                case ArenaType.LOADING_UI:
                    return LoadingUiArena.useArena(dataType);
                case ArenaType.SKYPLOT_UI:
                    return SkyPlotUiArena.useArena(dataType);
                case ArenaType.DETAILS_UI:
                    return DetailsUiArena.useArena(dataType);
                case ArenaType.PANORAMA_UI:
                    return PanoramaUiArena.useArena(dataType);
            }
            return null;
        }
    }
}
