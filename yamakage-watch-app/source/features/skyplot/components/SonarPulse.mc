import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

module Feature {
    module SkyPlot {
        module Components {
            module SonarPulse {
                function render(
                    dc as Graphics.Dc,
                    currentPx as Number,
                    currentPy as Number,
                    pulsePhase as Float,
                    color as Graphics.ColorType
                ) as Void {
                    var pulseRadius = 10 + Math.sin(pulsePhase) * 4;
                    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
                    dc.setPenWidth(2);
                    dc.drawCircle(currentPx, currentPy, pulseRadius.toNumber());
                    dc.setPenWidth(1);
                }
            }
        }
    }
}
