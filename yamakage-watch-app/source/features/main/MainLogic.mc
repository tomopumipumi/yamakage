import Toybox.Math;
import Toybox.Lang;

module Features {
    module Main {
        module MainLogic {
            function calculateSunPosition(
                progress as Float,
                cx as Number,
                cy as Number,
                radius as Float
            ) as Array<Number> {
                var angle = Math.PI * (1.0 - progress);
                var x = cx + (radius * Math.cos(angle)).toNumber();
                var y = cy - (radius * Math.sin(angle)).toNumber();
                return [x, y] as Array<Number>;
            }

            function updateSparkles(
                buffer as Array<Number or Float>,
                targetX as Number,
                targetY as Number
            ) as Void {
                var numParticles = buffer.size() / 3;

                for (var i = 0; i < numParticles; i++) {
                    var idx = i * 3;
                    var life = buffer[idx + 2].toFloat();

                    life -= 0.05;

                    if (life <= 0.0) {
                        var offsetX = (Math.rand() % 30) - 15;
                        var offsetY = (Math.rand() % 30) - 15;

                        buffer[idx] = targetX + offsetX;
                        buffer[idx + 1] = targetY + offsetY;
                        buffer[idx + 2] = 1.0 + (Math.rand() % 10) / 10.0;
                    } else {
                        buffer[idx + 2] = life;
                    }
                }
            }
        }
    }
}
