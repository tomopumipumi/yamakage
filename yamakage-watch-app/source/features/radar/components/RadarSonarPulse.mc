import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

module Features {
    module Radar {
        module Components {
            module RadarSonarPulse {
                function render(
                    dc as Graphics.Dc,
                    cx as Number,
                    cy as Number,
                    radius as Float,
                    sweepAngle as Float
                ) as Void {
                    var progress = sweepAngle / (Math.PI * 2.0);

                    var numRipples = 2;

                    for (var i = 0; i < numRipples; i++) {
                        var phase = progress + i.toFloat() / numRipples;
                        if (phase > 1.0) {
                            phase -= 1.0;
                        }

                        var currentRadius = radius * phase;

                        if (currentRadius < 2.0) {
                            continue;
                        }

                        if (phase < 0.2) {
                            dc.setColor(
                                Graphics.COLOR_GREEN,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.setPenWidth(1);
                        } else if (phase < 0.5) {
                            dc.setColor(
                                Graphics.COLOR_GREEN,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.setPenWidth(2);
                        } else if (phase < 0.85) {
                            dc.setColor(
                                Graphics.COLOR_DK_GRAY,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.setPenWidth(2);
                        } else {
                            dc.setColor(
                                Graphics.COLOR_DK_GRAY,
                                Graphics.COLOR_TRANSPARENT
                            );
                            dc.setPenWidth(1);
                        }

                        dc.drawCircle(cx, cy, currentRadius.toNumber());
                    }

                    dc.setPenWidth(1);
                }
            }
        }
    }
}
