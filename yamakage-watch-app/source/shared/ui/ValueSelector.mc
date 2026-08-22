import Toybox.Lang;
import Toybox.Graphics;

module Shared {
    module Ui {
        module ValueSelector {
            function render(
                dc as Graphics.Dc,
                x as Number,
                y as Number,
                w as Number,
                h as Number,
                label as String,
                valueText as String,
                isSelected as Boolean
            ) as Void {
                if (isSelected) {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillRoundedRectangle(x, y, w, h, 8);
                }

                _Label.render(dc, x, y, h, label);
                _Value.render(dc, x, y, w, h, valueText);
            }

            module _Label {
                function render(
                    dc as Graphics.Dc,
                    x as Number,
                    y as Number,
                    h as Number,
                    label as String
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        x + 12,
                        y + h / 2,
                        Graphics.FONT_SMALL,
                        label,
                        Graphics.TEXT_JUSTIFY_LEFT |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }

            module _Value {
                function render(
                    dc as Graphics.Dc,
                    x as Number,
                    y as Number,
                    w as Number,
                    h as Number,
                    valueText as String
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_GREEN,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.drawText(
                        x + w - 12,
                        y + h / 2,
                        Graphics.FONT_SMALL,
                        valueText,
                        Graphics.TEXT_JUSTIFY_RIGHT |
                            Graphics.TEXT_JUSTIFY_VCENTER
                    );
                }
            }
        }
    }
}
