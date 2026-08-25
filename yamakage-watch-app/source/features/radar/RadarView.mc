import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ApiSchema.SunDataIndex;
import Core.ApiSchema.MoonDataIndex;
import Hal.Sensor.CompassSensor;
import Shared.Logic.PositionConfigure;
import Shared.Logic.FontManager;
import Shared.Ui.PageIndicator;
import Shared.Core.Page;
import Shared.Core.Enums.TargetMode;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Consts.ToggleValues;

import Features.Radar.Components.RadarGrid;
import Features.Radar.Components.RadarArea;
import Features.Radar.Components.RadarSun;
import Features.Radar.Components.RadarMoon;
import Features.Radar.Components.RadarBeam;
import Features.Radar.Components.RadarSonarPulse;

using MonkeyHooks as MH;
using Core.AppArena.CoreArena as coreA;
using Core.AppArena.RadarUiArena as radarA;
using Core.CustomContext as mycx;

module Features {
    module Radar {
        class RadarView extends WatchUi.View {
            private var _tickCount as Number = 0;
            private var _sweepAngle as Float = 0.0;

            private var _w as Number = 0;
            private var _h as Number = 0;
            private var _cx as Number = 0;
            private var _cy as Number = 0;
            private var _radius as Float = 0.0;
            private var _nFont as Graphics.FontType?;

            private var _isAnimOn as Boolean = true;
            private var _mode as Number = TargetMode.SUN;

            private var _hasData as Boolean = false;
            private var _stepDeg as Number = 0;
            private var _profiles as ApiSchema.AzimuthProfilesArray?;
            private var _paths as ApiSchema.PathArray?;
            private var _fraction as Float = 1.0;
            private var _phase as Float = 0.5;

            function initialize() {
                View.initialize();
            }

            function onLayout(dc as Graphics.Dc) as Void {
                PositionConfigure.initializeGlobalLayout(dc);

                _w = MH.useNumber(coreA.DISPLAY_WIDTH).init(0).req();
                _h = MH.useNumber(coreA.DISPLAY_HEIGHT).init(0).req();
                _cx = MH.useNumber(coreA.CENTER_X).init(0).req();
                _cy = MH.useNumber(coreA.CENTER_Y).init(0).req();
                _radius = ((_w < _h ? _w : _h) / 2.0) * 0.75;

                var fontCx = MH.useFont(radarA.N_FONT);
                if (fontCx.get() == null) {
                    fontCx.set(
                        FontManager.findBestFont(
                            dc,
                            "N",
                            (_w * 0.2).toNumber(),
                            (_h * 0.1).toNumber()
                        )
                    );
                }
                _nFont = fontCx.get() as Graphics.FontType;
            }

            function onShow() as Void {
                _mode = MH.useNumber(coreA.TARGET_MODE)
                    .init(TargetMode.SUN)
                    .req();
                var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                    .init(ToggleValues.ON)
                    .req();
                _isAnimOn = animState.equals(ToggleValues.ON);

                refreshData();

                MH.watch(self, :onTargetModeChanged, [coreA.TARGET_MODE]);
                MH.watch(self, :onAnimConfigChanged, [SettingIds.ANIM_ENABLED]);
                MH.watch(self, :onSunDataChanged, [coreA.SUN_SHADOW_DATA]);
                MH.watch(self, :onMoonDataChanged, [coreA.MOON_SHADOW_DATA]);

                MH.SharedTimer.subscribe(self, :onTimerTick);
            }

            function onHide() as Void {
                MH.SharedTimer.unsubscribe(self, :onTimerTick);

                MH.unwatch(self, :onTargetModeChanged);
                MH.unwatch(self, :onAnimConfigChanged);
                MH.unwatch(self, :onSunDataChanged);
                MH.unwatch(self, :onMoonDataChanged);
            }

            function onTargetModeChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    _mode = vals[0] as Number;
                    refreshData();
                }
            }

            function onAnimConfigChanged(vals as Array) as Void {
                if (vals[0] != null) {
                    var animState = vals[0] as String;
                    _isAnimOn = animState.equals(ToggleValues.ON);
                }
            }

            function onSunDataChanged(vals as Array) as Void {
                if (_mode == TargetMode.SUN) {
                    refreshData();
                }
            }

            function onMoonDataChanged(vals as Array) as Void {
                if (_mode == TargetMode.MOON) {
                    refreshData();
                }
            }

            private function refreshData() as Void {
                var data = null;
                _hasData = false;

                if (_mode == TargetMode.SUN) {
                    data = mycx.useSunPayload(coreA.SUN_SHADOW_DATA).get();
                    if (data != null) {
                        _stepDeg = data[SunDataIndex.AZIMUTH_STEP] as Number;
                        _profiles =
                            data[SunDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _paths =
                            data[SunDataIndex.PATHS] as ApiSchema.PathArray;
                        _hasData = true;
                    }
                } else {
                    data = mycx.useMoonPayload(coreA.MOON_SHADOW_DATA).get();
                    if (data != null) {
                        _stepDeg = data[MoonDataIndex.AZIMUTH_STEP] as Number;
                        _fraction = data[MoonDataIndex.FRACTION] as Float;
                        _phase = data[MoonDataIndex.PHASE] as Float;
                        _profiles =
                            data[MoonDataIndex.PROFILES] as
                            ApiSchema.AzimuthProfilesArray;
                        _paths =
                            data[MoonDataIndex.PATHS] as ApiSchema.PathArray;
                        _hasData = true;
                    }
                }
            }

            function onTimerTick() as Void {
                _tickCount++;

                if (_isAnimOn) {
                    _sweepAngle += 0.05;
                    if (_sweepAngle > Math.PI * 2) {
                        _sweepAngle -= Math.PI * 2;
                    }
                }
                if (_isAnimOn || _tickCount % 2 == 0) {
                    WatchUi.requestUpdate();
                }
            }

            function onUpdate(dc as Graphics.Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();

                if (!_hasData) {
                    return;
                }

                var heading = CompassSensor.getHeadingDegrees();

                RadarGrid.render(dc, _cx, _cy, _radius, _nFont);
                RadarArea.render(dc, _profiles, _stepDeg, _cx, _cy, _radius);

                if (_mode == TargetMode.SUN) {
                    RadarSun.render(dc, _paths, _cx, _cy, _radius);
                } else {
                    RadarMoon.render(
                        dc,
                        _paths,
                        _cx,
                        _cy,
                        _radius,
                        _fraction,
                        _phase
                    );
                }

                if (heading != null) {
                    RadarBeam.render(
                        dc,
                        heading,
                        _profiles,
                        _stepDeg,
                        _cx,
                        _cy,
                        _radius
                    );
                }

                RadarSonarPulse.render(dc, _cx, _cy, _radius, _sweepAngle);

                PageIndicator.render(
                    dc,
                    Shared.Core.TOTAL_PAGES,
                    Page.RADAR,
                    _w,
                    _h
                );
            }
        }
    }
}
