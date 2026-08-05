import Toybox.Math;
import Toybox.Lang;
import Toybox.System;

(:background)
module Systems {
    (:background)
    module Crypt {
        function generateRandomSessionId() as String {
            Math.srand(System.getTimer());
            return Lang.format("$1$-$2$", [
                (Math.rand() & 0x7fffffff).format("%08X"),
                (Math.rand() & 0x7fffffff).format("%08X")
            ]);
        }
    }
}
