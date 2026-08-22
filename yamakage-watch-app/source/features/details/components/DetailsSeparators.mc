import Toybox.Lang;
import Toybox.Graphics;

module Features {
    module Details {
        module Components {
            module DetailsSeparators {
                function render(
                    dc as Graphics.Dc,
                    w as Number,
                    h as Number,
                    rows as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(1);

                    if (rows == 4) {
                        dc.drawLine(
                            (w * 0.2).toNumber(),
                            (h * 0.3).toNumber(),
                            (w * 0.8).toNumber(),
                            (h * 0.3).toNumber()
                        );
                        dc.drawLine(
                            (w * 0.2).toNumber(),
                            (h * 0.5).toNumber(),
                            (w * 0.8).toNumber(),
                            (h * 0.5).toNumber()
                        );
                        dc.drawLine(
                            (w * 0.2).toNumber(),
                            (h * 0.7).toNumber(),
                            (w * 0.8).toNumber(),
                            (h * 0.7).toNumber()
                        );
                    } else {
                        dc.drawLine(
                            (w * 0.2).toNumber(),
                            (h * 0.37).toNumber(),
                            (w * 0.8).toNumber(),
                            (h * 0.37).toNumber()
                        );
                        dc.drawLine(
                            (w * 0.2).toNumber(),
                            (h * 0.62).toNumber(),
                            (w * 0.8).toNumber(),
                            (h * 0.62).toNumber()
                        );
                    }
                }
            }
        }
    }
}
