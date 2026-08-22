import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Features {
    module Main {
        module Components {
            module MainBackground {
                function render(
                    dc as Graphics.Dc,
                    w as Number,
                    h as Number,
                    mode as Number
                ) as Void {
                    var objX = (w * 0.65).toNumber();
                    var objY = (h * 0.5).toNumber();
                    var r = (w * 0.15).toNumber();

                    if (mode == 0) {
                        _Sun.render(dc, objX, objY, r);
                    } else {
                        _Moon.render(dc, objX, objY, r);
                    }

                    _Mountains.render(dc, w, h);
                }
            }

            module _Sun {
                function render(
                    dc as Graphics.Dc,
                    x as Number,
                    y as Number,
                    r as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_ORANGE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(x, y, r);

                    dc.setPenWidth(3);
                    for (var j = 0; j < 8; j++) {
                        var angle = (j * Math.PI) / 4.0;
                        var r1 = r * 1.3;
                        var r2 = r * 1.7;
                        dc.drawLine(
                            x + (Math.cos(angle) * r1).toNumber(),
                            y + (Math.sin(angle) * r1).toNumber(),
                            x + (Math.cos(angle) * r2).toNumber(),
                            y + (Math.sin(angle) * r2).toNumber()
                        );
                    }
                    dc.setPenWidth(1);
                }
            }

            module _Moon {
                function render(
                    dc as Graphics.Dc,
                    x as Number,
                    y as Number,
                    r as Number
                ) as Void {
                    dc.setColor(
                        Graphics.COLOR_LT_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(x, y, r);

                    var offsetX = (r * 0.5).toNumber();
                    var offsetY = (r * 0.1).toNumber();
                    dc.setColor(
                        Graphics.COLOR_BLACK,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(x + offsetX, y + offsetY, r);
                }
            }

            module _Mountains {
                function render(
                    dc as Graphics.Dc,
                    w as Number,
                    h as Number
                ) as Void {
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
