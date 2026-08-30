import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

module Shared {
    module Logic {
        module IconFontManager {
            var resourceIds as Array<ResourceId> = [
                Rez.Fonts.IconFont40,
                Rez.Fonts.IconFont48,
                Rez.Fonts.IconFont62,
                Rez.Fonts.IconFont92
            ];

            function calculateBestIconFontIndex(
                dc as Graphics.Dc,
                w as Number,
                h as Number
            ) as Number {
                var maxWidth = (w * 0.15).toNumber();
                var maxHeight = (h * 0.15).toNumber();

                for (var i = resourceIds.size() - 1; i >= 0; i--) {
                    var testFont =
                        WatchUi.loadResource(resourceIds[i]) as
                        Graphics.FontType;
                    var dim = dc.getTextDimensions(
                        Icons.ICON_SUNRISE,
                        testFont
                    );
                    if (dim[0] <= maxWidth && dim[1] <= maxHeight) {
                        return i;
                    }
                }
                return 0;
            }

            function loadIconFontResource(
                index as Number
            ) as Graphics.FontType {
                return (
                    WatchUi.loadResource(resourceIds[index]) as
                    Graphics.FontType
                );
            }
        }
    }
}
