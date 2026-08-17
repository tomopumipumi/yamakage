import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

module Hal {
    module Strings {
        module Icons {
            function getIconFonts() as Array<Graphics.FontType> {
                var fontSymbols = [
                    Rez.Fonts.IconFont92,
                    Rez.Fonts.IconFont62,
                    Rez.Fonts.IconFont48,
                    Rez.Fonts.IconFont40
                ];

                var iconFonts = new [fontSymbols.size()];
                for (var i = 0; i < fontSymbols.size(); i++) {
                    iconFonts[i] = WatchUi.loadResource(fontSymbols[i]);
                }

                return iconFonts;
            }
        }

        function getAppTitle() as String {
            return WatchUi.loadResource(Rez.Strings.AppName);
        }

        function getTimeDefaultLabel() as String {
            return WatchUi.loadResource(Rez.Strings.TimeDefaultLabel);
        }

        function getCommunicatingLabel() as String {
            return WatchUi.loadResource(Rez.Strings.Communicating);
        }

        function getUpdateFailedLabel() as String {
            return WatchUi.loadResource(Rez.Strings.UpdateFailed);
        }

        function getUpdatingLabel() as String {
            return WatchUi.loadResource(Rez.Strings.Updating);
        }

        function getFailBackgroundProcessMsg() as String {
            return WatchUi.loadResource(Rez.Strings.FailBackgroundProcessMsg);
        }

        function getFailConnectPhoneMsg() as String {
            return WatchUi.loadResource(Rez.Strings.FailConnectPhoneMsg);
        }
    }
}
