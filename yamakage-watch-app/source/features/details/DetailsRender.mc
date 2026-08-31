import Toybox.Lang;
import Toybox.Graphics;
import Shared.Core.Page;
import Shared.Core.Enums.TargetMode;
import Shared.Icons;
import Shared.Ui.PageIndicator;

import Features.Details.DetailsLogic;
import Features.Details.Components.DetailsRow;
import Features.Details.Components.DetailsMoonRow;
import Features.Details.Components.DetailsSeparators;

module Features {
    module Details {
        module DetailsRender {
            function render(dc as Graphics.Dc, props as Array) as Void {
                var w = props[DetailsProps.W] as Number;
                var h = props[DetailsProps.H] as Number;
                var hasData = props[DetailsProps.HAS_DATA] as Boolean;

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                if (!hasData) {
                    return;
                }

                var mode = props[DetailsProps.MODE] as Number;
                var layoutCtx = props[DetailsProps.LAYOUT_CTX] as Array;
                var sunriseStr = props[DetailsProps.SUNRISE_STR] as String;
                var sunsetStr = props[DetailsProps.SUNSET_STR] as String;
                var elevStr = props[DetailsProps.ELEV_STR] as String;

                var riseLabel =
                    mode == TargetMode.MOON ? "MOONRISE" : "SUNRISE";
                var setLabel = mode == TargetMode.MOON ? "MOONSET" : "SUNSET";
                var riseColor =
                    mode == TargetMode.MOON
                        ? Graphics.COLOR_WHITE
                        : Graphics.COLOR_YELLOW;
                var setColor =
                    mode == TargetMode.MOON
                        ? Graphics.COLOR_LT_GRAY
                        : Graphics.COLOR_PURPLE;
                var riseIcon =
                    mode == TargetMode.MOON
                        ? Icons.ICON_MOONRISE
                        : Icons.ICON_SUNRISE;
                var setIcon =
                    mode == TargetMode.MOON
                        ? Icons.ICON_MOONSET
                        : Icons.ICON_SUNSET;

                var numRows = mode == TargetMode.MOON ? 4 : 3;
                DetailsSeparators.render(dc, w, h, numRows);

                switch (mode) {
                    case TargetMode.SUN:
                        DetailsRow.render(
                            dc,
                            (h * 0.25).toNumber(),
                            riseLabel,
                            sunriseStr,
                            riseColor,
                            riseIcon,
                            layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (h * 0.5).toNumber(),
                            setLabel,
                            sunsetStr,
                            setColor,
                            setIcon,
                            layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (h * 0.75).toNumber(),
                            "HEADING",
                            elevStr,
                            Graphics.COLOR_GREEN,
                            Icons.ICON_ELEVATION_ANGLE,
                            layoutCtx
                        );
                        break;

                    case TargetMode.MOON:
                        var illumStr = props[DetailsProps.ILLUM_STR] as String;
                        var fraction = props[DetailsProps.FRACTION] as Float;
                        var phase = props[DetailsProps.PHASE] as Float;

                        DetailsRow.render(
                            dc,
                            (h * 0.2).toNumber(),
                            riseLabel,
                            sunriseStr,
                            riseColor,
                            riseIcon,
                            layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (h * 0.4).toNumber(),
                            setLabel,
                            sunsetStr,
                            setColor,
                            setIcon,
                            layoutCtx
                        );
                        DetailsRow.render(
                            dc,
                            (h * 0.6).toNumber(),
                            "HEADING",
                            elevStr,
                            Graphics.COLOR_GREEN,
                            Icons.ICON_ELEVATION_ANGLE,
                            layoutCtx
                        );
                        DetailsMoonRow.render(
                            dc,
                            (h * 0.8).toNumber(),
                            "ILLUM",
                            illumStr,
                            Graphics.COLOR_BLUE,
                            fraction,
                            phase,
                            layoutCtx
                        );
                        break;
                }

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.DETAILS,
                    w,
                    h
                );
            }
        }
    }
}
