import Toybox.Lang;
import Toybox.Test;
import Toybox.Math;

using MonkeyHooks.TestUtils as MHTest;

module Features {
    module Error {
        (:test)
        module TestFixture {
            function createDummyProps() as Array {
                var props = new [ErrorProps.DATA_SIZE];
                props[ErrorProps.W] = 240;
                props[ErrorProps.H] = 240;
                props[ErrorProps.CX] = 120;
                props[ErrorProps.IS_ANIM_ON] = true;
                props[ErrorProps.ERR_MSG] = "Bluetooth Offline";
                props[ErrorProps.PULSE] = Math.PI;
                return props;
            }
        }
    }
}
