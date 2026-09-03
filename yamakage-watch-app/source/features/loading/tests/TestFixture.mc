import Toybox.Lang;
import Toybox.Test;
import Toybox.Graphics;
import Shared.Core.Enums.TargetMode;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Loading {
        (:test)
        module TestFixture {
            function createDummyProps() as Array {
                var props = new [LoadingProps.DATA_SIZE];
                props[LoadingProps.W] = 240;
                props[LoadingProps.H] = 240;
                props[LoadingProps.CX] = 120;
                props[LoadingProps.FONT] = Graphics.FONT_TINY;
                props[LoadingProps.MODE] = TargetMode.SUN;
                props[LoadingProps.IS_ANIM_ON] = true;
                props[LoadingProps.MSG] = "Calculating...";
                props[LoadingProps.ANGLE] = 0.5;

                return props;
            }
        }
    }
}
