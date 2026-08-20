import Toybox.Lang;
import Toybox.Graphics;
import Core.ApiSchema;

using MonkeyHooks as MH;

module Core {
    module CustomContext {
        class PayloadContext {
            private var _cx as MH.Context;
            function initialize(cx as MH.Context) {
                _cx = cx;
            }
            function get() as ApiSchema.ShadowDataPayload? {
                return _cx.get() as ApiSchema.ShadowDataPayload?;
            }
            function req() as ApiSchema.ShadowDataPayload {
                var val = _cx.get();
                if (val == null) {
                    throw new Lang.InvalidValueException(
                        "MonkeyHooks: req() called but value is null!"
                    );
                }
                return val as ApiSchema.ShadowDataPayload;
            }
            function set(val as ApiSchema.ShadowDataPayload?) as Void {
                _cx.set(val);
            }
            function setSilent(val as ApiSchema.ShadowDataPayload?) as Void {
                _cx.setSilent(val);
            }
            function init(
                val as ApiSchema.ShadowDataPayload
            ) as PayloadContext {
                _cx.init(val);
                return self;
            }
            function subscribe(listener as Lang.Method) as Void {
                _cx.subscribe(listener);
            }
            function unsubscribe(listener as Lang.Method) as Void {
                _cx.unsubscribe(listener);
            }
        }
        function usePayload(key as Object) as PayloadContext {
            return new PayloadContext(MH.useArena(key));
        }
    }
}
