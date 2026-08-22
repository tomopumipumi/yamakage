import Toybox.Lang;
import Toybox.Graphics;
import Shared.Core.Consts.ToggleValues;
import Shared.Core.Consts.SettingIds;
import Shared.Core.Enums.TargetMode;
import Shared.Ui.SunIcon;
import Shared.Ui.MoonIcon;
import Features.Main.MainLogic;

using MonkeyHooks as MH;

module Features {
    module Main {
        module Components {
            module MainSunAnimation {
                function render(
                    dc as Graphics.Dc,
                    progress as Float,
                    w as Number,
                    h as Number,
                    cx as Number,
                    mode as Number
                ) as Void {
                    var cy = (h * 0.65).toNumber();
                    var radius = w * 0.45;

                    var pos = MainLogic.calculateSunPosition(
                        progress,
                        cx,
                        cy,
                        radius
                    );
                    var targetX = pos[0];
                    var targetY = pos[1];

                    var animState = MH.useStorageString(SettingIds.ANIM_ENABLED)
                        .init(ToggleValues.ON)
                        .req();
                    if (animState.equals(ToggleValues.ON)) {
                        var numParticles = 15;
                        var sparkleBuffer = MH.useArrayBuffer(
                            :main_sparkles,
                            numParticles * 3
                        ).req();
                        MainLogic.updateSparkles(
                            sparkleBuffer,
                            targetX,
                            targetY
                        );

                        for (var i = 0; i < numParticles; i++) {
                            var idx = i * 3;
                            var pX = sparkleBuffer[idx].toNumber();
                            var pY = sparkleBuffer[idx + 1].toNumber();
                            var life = sparkleBuffer[idx + 2].toFloat();

                            if (life > 0.0) {
                                var size = (life * 2).toNumber();
                                if (size < 1) {
                                    size = 1;
                                }

                                if (mode == TargetMode.SUN) {
                                    dc.setColor(
                                        life > 1.0
                                            ? Graphics.COLOR_WHITE
                                            : Graphics.COLOR_YELLOW,
                                        Graphics.COLOR_TRANSPARENT
                                    );
                                } else {
                                    dc.setColor(
                                        life > 1.0
                                            ? Graphics.COLOR_WHITE
                                            : Graphics.COLOR_LT_GRAY,
                                        Graphics.COLOR_TRANSPARENT
                                    );
                                }

                                dc.drawLine(pX - size, pY, pX + size, pY);
                                dc.drawLine(pX, pY - size, pX, pY + size);
                            }
                        }
                    }

                    if (mode == TargetMode.SUN) {
                        SunIcon.render(dc, targetX, targetY);
                    } else {
                        MoonIcon.render(dc, targetX, targetY, 0.25, 0.25, 6);
                    }
                }
            }
        }
    }
}
