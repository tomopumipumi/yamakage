import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Main {
        (:test)
        module TestFixture {
            function _createFilledArray(size as Number) as Array<Float> {
                var arr = new [size] as Array<Float>;
                for (var i = 0; i < size; i++) {
                    arr[i] = 0.0;
                }
                return arr;
            }

            function createSparkleBuffer() as Array<Float> {
                return _createFilledArray(45);
            }

            function createDummyProps() as Array {
                var props = new [MainProps.DATA_SIZE];

                props[MainProps.W] = 240;
                props[MainProps.H] = 240;
                props[MainProps.CX] = 120;
                props[MainProps.TITLE_FONT] = Graphics.FONT_LARGE;
                props[MainProps.START_BTN_FONT] = Graphics.FONT_MEDIUM;
                props[MainProps.START_BTN_WIDTH] = 120;
                props[MainProps.START_BTN_HEIGHT] = 40;
                props[MainProps.MODE] = TargetMode.SUN;
                props[MainProps.IS_ANIM_ON] = true;
                props[MainProps.PROGRESS] = 0.5;
                props[MainProps.SPARKLE_BUFFER] = createSparkleBuffer();
                props[MainProps.GPS_TEXT] = "GPS: OK";
                props[MainProps.GPS_COLOR] = Graphics.COLOR_GREEN;
                props[MainProps.IS_GPS_READY] = true;

                return props;
            }
        }
    }
}
