import Toybox.Lang;
import Toybox.Graphics;
import Core.ArenaConfig;
import Core.ArenaConfig.ArenaType;
import Core.Arena.CoreArena;
import Core.Arena.DetailsUiArena;

module Features {
    module Details {
        module Components {
            module DetailsRow {
                function render(
                    dc as Graphics.Dc,
                    centerY as Number,
                    label as String,
                    value as String,
                    accentColor as Graphics.ColorType,
                    iconText as String
                ) as Void {
                    var w =
                        ArenaConfig.useArena(
                            ArenaType.CORE,
                            CoreArena.DataType.DISPLAY_WIDTH
                        ).get() as Number;

                    var labelFont =
                        ArenaConfig.useArena(
                            ArenaType.DETAILS_UI,
                            DetailsUiArena.DataType.LABEL_FONT
                        ).get() as Graphics.FontType;
                    var valueFont =
                        ArenaConfig.useArena(
                            ArenaType.DETAILS_UI,
                            DetailsUiArena.DataType.VALUE_FONT
                        ).get() as Graphics.FontType;
                    var iconFont =
                        ArenaConfig.useArena(
                            ArenaType.DETAILS_UI,
                            DetailsUiArena.DataType.ICON_FONT
                        ).get() as Graphics.FontType;

                    var iconX = (w * 0.32).toNumber();
                    var textX = (w * 0.45).toNumber();

                    dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        iconX,
                        centerY,
                        iconFont,
                        iconText,
                        Graphics.TEXT_JUSTIFY_CENTER |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );

                    var lblHeight = dc.getFontHeight(labelFont);
                    var valHeight = dc.getFontHeight(valueFont);
                    var totalHeight = lblHeight + valHeight - 4;
                    var startY = centerY - totalHeight / 2;

                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        textX,
                        startY,
                        labelFont,
                        label,
                        Graphics.TEXT_JUSTIFY_LEFT
                    );

                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        textX,
                        startY + lblHeight - 4,
                        valueFont,
                        value,
                        Graphics.TEXT_JUSTIFY_LEFT
                    );
                }
            }
        }
    }
}
