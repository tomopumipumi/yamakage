import Toybox.Lang;
import Toybox.Graphics;

module Features {
    module Details {
        module Components {
            module DetailsSeparators {
                function render(
                    dc as Graphics.Dc,
                    w as Number,
                    h as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.setPenWidth(1);

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
