import Toybox.Lang;
import Core.ApiSchema;

using MonkeyHooks as MH;

module Core {
    module CustomContext {
        class SunPayloadContext {
            private var _cx as MH.Context;
            function initialize(cx as MH.Context) {
                _cx = cx;
            }
            function get() as ApiSchema.SunShadowPayload? {
                return _cx.get() as ApiSchema.SunShadowPayload?;
            }
            function req() as ApiSchema.SunShadowPayload {
                var val = _cx.get();
                if (val == null) {
                    throw new Lang.InvalidValueException(
                        "MonkeyHooks: Sun Payload req() called but value is null!"
                    );
                }
                return val as ApiSchema.SunShadowPayload;
            }
            function set(val as ApiSchema.SunShadowPayload?) as Void {
                _cx.set(val);
            }
            function setSilent(val as ApiSchema.SunShadowPayload?) as Void {
                _cx.setSilent(val);
            }
            function init(
                val as ApiSchema.SunShadowPayload
            ) as SunPayloadContext {
                _cx.init(val);
                return self;
            }
        }

        class MoonPayloadContext {
            private var _cx as MH.Context;
            function initialize(cx as MH.Context) {
                _cx = cx;
            }
            function get() as ApiSchema.MoonShadowPayload? {
                return _cx.get() as ApiSchema.MoonShadowPayload?;
            }
            function req() as ApiSchema.MoonShadowPayload {
                var val = _cx.get();
                if (val == null) {
                    throw new Lang.InvalidValueException(
                        "MonkeyHooks: Moon Payload req() called but value is null!"
                    );
                }
                return val as ApiSchema.MoonShadowPayload;
            }
            function set(val as ApiSchema.MoonShadowPayload?) as Void {
                _cx.set(val);
            }
            function setSilent(val as ApiSchema.MoonShadowPayload?) as Void {
                _cx.setSilent(val);
            }
            function init(
                val as ApiSchema.MoonShadowPayload
            ) as MoonPayloadContext {
                _cx.init(val);
                return self;
            }
        }

        function useSunPayload(key as Object) as SunPayloadContext {
            return new SunPayloadContext(MH.useArena(key));
        }
        function useMoonPayload(key as Object) as MoonPayloadContext {
            return new MoonPayloadContext(MH.useArena(key));
        }
    }
}
