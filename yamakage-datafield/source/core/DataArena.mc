import Toybox.Lang;
import Toybox.Graphics;
import Hal.Strings;

module Core {
    module DataArena {
        module UiArena {
            var sunriseTime as String = Strings.getTimeDefaultLabel();
            var sunsetTime as String = Strings.getTimeDefaultLabel();
            var syncStatus as String = "WAITING FOR GPS...";
            var isFailed as Boolean = false;
            var currentSunset as Number = 0;
            var currentSunrise as Number = 0;

            module ContentsPositionArena {
                var isCompactMode as Boolean = false;

                module StatusBarArena {
                    var labelX as Number = 0;
                    var labelY as Number = 0;
                    var labelJustify as Number = Graphics.TEXT_JUSTIFY_CENTER;
                    var lineStartX as Number = 0;
                    var lineStartY as Number = 0;
                    var lineEndX as Number = 0;
                    var lineEndY as Number = 0;
                }

                module EventRowArena {
                    var iconX as Number = 0;
                    var sunrizeY as Number = 0;
                    var sunsetY as Number = 0;
                    var timeX as Number = 0;
                    var timeJustify as Number = Graphics.TEXT_JUSTIFY_CENTER;
                }

                module WatermarkArena {
                    var labelX as Number = 0;
                    var labelY as Number = 0;
                    var justify as Number = Graphics.TEXT_JUSTIFY_CENTER;
                }
            }
        }
    }
}
