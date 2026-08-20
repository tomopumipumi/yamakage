import Toybox.Lang;
import Toybox.WatchUi;
import Core.ApiSchema;

module Core {
    module AppArena {
        module CoreArena {
            enum {
                DISPLAY_WIDTH = 0,
                DISPLAY_HEIGHT,
                CENTER_X,
                CENTER_Y,
                CURRENT_SHADOW_DATA,
                LAST_ERROR,
                SESSION_ID
            }
        }

        module DetailsUiArena {
            enum {
                LABEL_FONT = 100,
                VALUE_FONT,
                ICON_FONT
            }
        }

        module LoadingUiArena {
            enum {
                MSG_FONT = 200,
                MSG_TEXT
            }
        }

        module MainUiArena {
            enum {
                TITLE_FONT = 300,
                BTN_FONT,
                BTN_WIDTH,
                BTN_HEIGHT,
                GPS_TEXT,
                GPS_COLOR,
                IS_GPS_READY
            }
        }

        module PanoramaUiArena {
            enum {
                ICON_FONT = 400
            }
        }

        module RadarUiArena {
            enum {
                N_FONT = 500
            }
        }

        module SkyPlotUiArena {
            enum {
                N_FONT = 600,
                ICON_FONT
            }
        }
    }
}
