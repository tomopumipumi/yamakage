import Toybox.Lang;
import Toybox.Graphics;

module Features {
    module Main {
        module Components {
            module MainBackground {
                function render(
                    dc as Graphics.Dc,
                    w as Number,
                    h as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_ORANGE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(
                        (w * 0.65).toNumber(),
                        (h * 0.5).toNumber(),
                        (w * 0.15).toNumber()
                    );

                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillPolygon([
                        [0, h],
                        [(w * 0.1).toNumber(), (h * 0.55).toNumber()],
                        [(w * 0.4).toNumber(), (h * 0.7).toNumber()],
                        [(w * 0.8).toNumber(), (h * 0.45).toNumber()],
                        [w, (h * 0.6).toNumber()],
                        [w, h]
                    ]);

                    dc.setColor(
                        Graphics.COLOR_DK_GREEN,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillPolygon([
                        [0, h],
                        [(w * 0.25).toNumber(), (h * 0.65).toNumber()],
                        [(w * 0.5).toNumber(), (h * 0.8).toNumber()],
                        [(w * 0.9).toNumber(), (h * 0.6).toNumber()],
                        [w, (h * 0.75).toNumber()],
                        [w, h]
                    ]);
                }
            }
        }
    }
}
