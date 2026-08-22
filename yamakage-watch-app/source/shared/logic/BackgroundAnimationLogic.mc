import Toybox.Lang;
import Toybox.Math;

module Shared {
    module Logic {
        module BackgroundAnimationLogic {
            function updateStars(
                buffer as Array<Number or Float>,
                width as Number,
                height as Number,
                isAnimOn as Boolean
            ) as Void {
                var numStars = buffer.size() / 3;
                for (var i = 0; i < numStars; i++) {
                    var idx = i * 3;
                    if (buffer[idx] == 0.0 && buffer[idx + 1] == 0.0) {
                        buffer[idx] = Math.rand() % width;
                        buffer[idx + 1] = Math.rand() % height;
                        buffer[idx + 2] =
                            ((Math.rand() % 100) / 100.0) * Math.PI * 2;
                    }
                    if (isAnimOn) {
                        var phase = buffer[idx + 2].toFloat() + 0.15;
                        if (phase > Math.PI * 2) {
                            phase -= Math.PI * 2;
                            if (Math.rand() % 10 > 7) {
                                buffer[idx] = Math.rand() % width;
                                buffer[idx + 1] = Math.rand() % height;
                            }
                        }
                        buffer[idx + 2] = phase;
                    } else {
                        buffer[idx + 2] = Math.PI / 2.0;
                    }
                }
            }

            function updateClouds(
                buffer as Array<Number or Float>,
                width as Number,
                height as Number,
                isAnimOn as Boolean
            ) as Void {
                var numClouds = buffer.size() / 4;
                for (var i = 0; i < numClouds; i++) {
                    var idx = i * 4;
                    if (
                        buffer[idx] == 0.0 &&
                        buffer[idx + 1] == 0.0 &&
                        buffer[idx + 2] == 0.0
                    ) {
                        buffer[idx] = Math.rand() % width;
                        buffer[idx + 1] =
                            Math.rand() % (height * 0.8).toNumber();
                        buffer[idx + 2] = ((Math.rand() % 15) + 5) / 10.0;
                        buffer[idx + 3] = (Math.rand() % 3) + 2;
                    }
                    if (isAnimOn) {
                        var x =
                            buffer[idx].toFloat() + buffer[idx + 2].toFloat();
                        if (x > width + 40) {
                            x = -40.0;
                            buffer[idx + 1] =
                                Math.rand() % (height * 0.8).toNumber();
                            buffer[idx + 2] = ((Math.rand() % 15) + 5) / 10.0;
                            buffer[idx + 3] = (Math.rand() % 3) + 2;
                        }
                        buffer[idx] = x;
                    }
                }
            }
        }
    }
}
