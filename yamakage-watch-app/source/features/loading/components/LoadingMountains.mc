import Toybox.Lang;
import Toybox.Graphics;

module Features {
    module Loading {
        module Components {
            module LoadingMountains {
                function render(
                    dc as Graphics.Dc,
                    width as Number,
                    height as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillPolygon([
                        [0, height],
                        [(width * 0.1).toNumber(), (height * 0.55).toNumber()],
                        [(width * 0.4).toNumber(), (height * 0.7).toNumber()],
                        [(width * 0.8).toNumber(), (height * 0.45).toNumber()],
                        [width, (height * 0.6).toNumber()],
                        [width, height]
                    ]);

                    dc.setColor(
                        Graphics.COLOR_DK_GREEN,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillPolygon([
                        [0, height],
                        [(width * 0.25).toNumber(), (height * 0.65).toNumber()],
                        [(width * 0.5).toNumber(), (height * 0.8).toNumber()],
                        [(width * 0.9).toNumber(), (height * 0.6).toNumber()],
                        [width, (height * 0.75).toNumber()],
                        [width, height]
                    ]);
                }
            }
        }
    }
}
