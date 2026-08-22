import Toybox.Lang;
import Toybox.Graphics;

module Shared {
    module Ui {
        module Toggle {
            function render(
                dc as Graphics.Dc,
                x as Number,
                y as Number,
                w as Number,
                h as Number,
                label as String,
                isOn as Boolean,
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

                _Switch.render(dc, x, y, w, h, isOn);
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

            module _Switch {
                function render(
                    dc as Graphics.Dc,
                    x as Number,
                    y as Number,
                    w as Number,
                    h as Number,
                    isOn as Boolean
                ) as Void {
                    var pillW = 48;
                    var pillH = 24;
                    var pillX = x + w - pillW - 12;
                    var pillY = y + (h - pillH) / 2;

                    dc.setColor(
                        isOn ? Graphics.COLOR_GREEN : 0x333333,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillRoundedRectangle(
                        pillX,
                        pillY,
                        pillW,
                        pillH,
                        pillH / 2
                    );
                    _Circle.render(dc, pillX, pillY, pillW, pillH, isOn);
                }
                module _Circle {
                    function render(
                        dc as Graphics.Dc,
                        pillX as Number,
                        pillY as Number,
                        pillW as Number,
                        pillH as Number,
                        isOn as Boolean
                    ) as Void {
                        var knobR = pillH / 2 - 2;
                        var knobX = isOn
                            ? pillX + pillW - knobR - 2
                            : pillX + knobR + 2;
                        var knobY = pillY + pillH / 2;

                        dc.setColor(
                            Graphics.COLOR_WHITE,
                            Graphics.COLOR_TRANSPARENT
                        );
                        dc.fillCircle(knobX, knobY, knobR);
                    }
                }
            }
        }
    }
}
