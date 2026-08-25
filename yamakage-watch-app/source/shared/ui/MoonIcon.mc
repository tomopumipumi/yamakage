import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;

module Shared {
    module Ui {
        module MoonIcon {
            class _MoonCalculator {
                private const NUM_PTS = 21;

                private var _cachedPts as Array<[Lang.Numeric, Lang.Numeric]>? =
                    null;
                private var _lastFraction as Float? = null;
                private var _lastPhase as Float? = null;
                private var _lastRadius as Number? = null;

                function getBasePolygon(
                    fraction as Float,
                    phase as Float,
                    radius as Number
                ) as Array<[Lang.Numeric, Lang.Numeric]> {
                    if (
                        _cachedPts != null &&
                        _lastFraction == fraction &&
                        _lastPhase == phase &&
                        _lastRadius == radius
                    ) {
                        return (
                            _cachedPts as Array<[Lang.Numeric, Lang.Numeric]>
                        );
                    }

                    var isWaxing = phase < 0.5;
                    var dir = isWaxing ? 1.0 : -1.0;
                    var tFactor = 1.0 - 2.0 * fraction;

                    var pts =
                        new [NUM_PTS * 2] as
                        Array<[Lang.Numeric, Lang.Numeric]>;

                    _computeBrightLimb(pts, dir, radius);
                    _computeTerminatorLimb(pts, dir, radius, tFactor);

                    _lastFraction = fraction;
                    _lastPhase = phase;
                    _lastRadius = radius;
                    _cachedPts = pts;

                    return pts;
                }

                private function _computeBrightLimb(
                    pts as Array<[Lang.Numeric, Lang.Numeric]>,
                    dir as Float,
                    radius as Number
                ) as Void {
                    for (var i = 0; i < NUM_PTS; i++) {
                        var angle =
                            -Math.PI / 2.0 + (Math.PI * i) / (NUM_PTS - 1);
                        var px = dir * radius * Math.cos(angle);
                        var py = radius * Math.sin(angle);
                        pts[i] =
                            [
                                Math.round(px).toNumber(),
                                Math.round(py).toNumber()
                            ] as [Lang.Numeric, Lang.Numeric];
                    }
                }

                private function _computeTerminatorLimb(
                    pts as Array<[Lang.Numeric, Lang.Numeric]>,
                    dir as Float,
                    radius as Number,
                    tFactor as Float
                ) as Void {
                    for (var i = 0; i < NUM_PTS; i++) {
                        var angle =
                            Math.PI / 2.0 - (Math.PI * i) / (NUM_PTS - 1);
                        var px = dir * radius * Math.cos(angle) * tFactor;
                        var py = radius * Math.sin(angle);
                        pts[NUM_PTS + i] =
                            [
                                Math.round(px).toNumber(),
                                Math.round(py).toNumber()
                            ] as [Lang.Numeric, Lang.Numeric];
                    }
                }
            }

            var _calculator = new _MoonCalculator();

            var _renderBuffer as Array<[Lang.Numeric, Lang.Numeric]>? = null;

            function render(
                dc as Graphics.Dc,
                x as Number,
                y as Number,
                fraction as Float,
                phase as Float,
                radius as Number
            ) as Void {
                var isNewMoon = fraction < 0.02;
                var isFullMoon = fraction > 0.98;

                if (isNewMoon) {
                    dc.setColor(
                        Graphics.COLOR_DK_GRAY,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(x, y, radius);
                    return;
                }

                if (isFullMoon) {
                    dc.setColor(
                        Graphics.COLOR_WHITE,
                        Graphics.COLOR_TRANSPARENT
                    );
                    dc.fillCircle(x, y, radius);
                    return;
                }

                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, radius);

                var basePts =
                    _calculator.getBasePolygon(fraction, phase, radius) as
                    Array<[Lang.Numeric, Lang.Numeric]>;
                var totalPts = basePts.size();

                if (_renderBuffer == null || _renderBuffer.size() != totalPts) {
                    _renderBuffer =
                        new [totalPts] as Array<[Lang.Numeric, Lang.Numeric]>;
                    for (var i = 0; i < totalPts; i++) {
                        _renderBuffer[i] =
                            [0.0, 0.0] as [Lang.Numeric, Lang.Numeric];
                    }
                }

                var renderPts =
                    _renderBuffer as Array<[Lang.Numeric, Lang.Numeric]>;

                for (var i = 0; i < totalPts; i++) {
                    renderPts[i][0] = basePts[i][0] + x;
                    renderPts[i][1] = basePts[i][1] + y;
                }

                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillPolygon(renderPts);
            }
        }
    }
}
