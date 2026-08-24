import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Position;
import Toybox.WatchUi;

module MonkeyHooks {
    class FontContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Graphics.FontType? {
            return _cx.get() as Graphics.FontType?;
        }
        function req() as Graphics.FontType {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Font req() failed."
                );
            }
            return val as Graphics.FontType;
        }
        function set(val as Graphics.FontType?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Graphics.FontType?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Graphics.FontType) as FontContext {
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
    function useFont(key as Object) as FontContext {
        return new FontContext(useArena(key));
    }

    class ColorContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Graphics.ColorType? {
            return _cx.get() as Graphics.ColorType?;
        }
        function req() as Graphics.ColorType {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Color req() failed."
                );
            }
            return val as Graphics.ColorType;
        }
        function set(val as Graphics.ColorType?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Graphics.ColorType?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Graphics.ColorType) as ColorContext {
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
    function useColor(key as Object) as ColorContext {
        return new ColorContext(useArena(key));
    }

    class MomentContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Time.Moment? {
            return _cx.get() as Time.Moment?;
        }
        function req() as Time.Moment {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Moment req() failed."
                );
            }
            return val as Time.Moment;
        }
        function set(val as Time.Moment?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Time.Moment?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Time.Moment) as MomentContext {
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
    function useMoment(key as Object) as MomentContext {
        return new MomentContext(useArena(key));
    }

    class LocationContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as Position.Location? {
            return _cx.get() as Position.Location?;
        }
        function req() as Position.Location {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: Location req() failed."
                );
            }
            return val as Position.Location;
        }
        function set(val as Position.Location?) as Void {
            _cx.set(val);
        }
        function setSilent(val as Position.Location?) as Void {
            _cx.setSilent(val);
        }
        function init(val as Position.Location) as LocationContext {
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
    function useLocation(key as Object) as LocationContext {
        return new LocationContext(useArena(key));
    }

    class BitmapResourceContext {
        private var _cx as Context;
        function initialize(cx as Context) {
            _cx = cx;
        }
        function get() as WatchUi.BitmapResource? {
            return _cx.get() as WatchUi.BitmapResource?;
        }
        function req() as WatchUi.BitmapResource {
            var val = _cx.get();
            if (val == null) {
                throw new Lang.InvalidValueException(
                    "MonkeyHooks: BitmapResource req() failed."
                );
            }
            return val as WatchUi.BitmapResource;
        }
        function set(val as WatchUi.BitmapResource?) as Void {
            _cx.set(val);
        }
        function setSilent(val as WatchUi.BitmapResource?) as Void {
            _cx.setSilent(val);
        }
        function init(val as WatchUi.BitmapResource) as BitmapResourceContext {
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
    function useBitmapResource(key as Object) as BitmapResourceContext {
        return new BitmapResourceContext(useArena(key));
    }
}
