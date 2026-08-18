import Toybox.Lang;
import Toybox.WatchUi;
import Core.ApiSchema;
import Core.ArenaConfig;

module Core {
    module Arena {
        module CoreArena {
            var _arena as ArenaImpl? = null;
            var _cxs as Dictionary<Number, ArenaConfig.Context>? = null;

            module DataType {
                typedef DataTypeDef as Number;
                enum {
                    DISPLAY_WIDTH,
                    DISPLAY_HEIGHT,
                    CENTER_X,
                    CENTER_Y,
                    CURRENT_SHADOW_DATA,
                    LAST_ERROR,
                    SESSION_ID
                }
            }

            function useArena(
                dataType as DataType.DataTypeDef
            ) as ArenaConfig.Context {
                if (_arena == null) {
                    _arena = new ArenaImpl();
                    _cxs = ({}) as Dictionary<Number, ArenaConfig.Context>;
                }

                var cached = _cxs.get(dataType);
                if (cached != null) {
                    return cached as ArenaConfig.Context;
                }

                var getter = null;
                var setter = null;

                switch (dataType) {
                    case DataType.DISPLAY_WIDTH:
                        getter = _arena.method(:getDisplayWidth);
                        setter = _arena.method(:setDisplayWidth);
                        break;
                    case DataType.DISPLAY_HEIGHT:
                        getter = _arena.method(:getDisplayHeight);
                        setter = _arena.method(:setDisplayHeight);
                        break;
                    case DataType.CENTER_X:
                        getter = _arena.method(:getCenterX);
                        setter = _arena.method(:setCenterX);
                        break;
                    case DataType.CENTER_Y:
                        getter = _arena.method(:getCenterY);
                        setter = _arena.method(:setCenterY);
                        break;
                    case DataType.CURRENT_SHADOW_DATA:
                        getter = _arena.method(:getCurrentShadowData);
                        setter = _arena.method(:setCurrentShadowData);
                        break;
                    case DataType.LAST_ERROR:
                        getter = _arena.method(:getLastError);
                        setter = _arena.method(:setLastError);
                        break;
                    case DataType.SESSION_ID:
                        getter = _arena.method(:getSessionId);
                        setter = _arena.method(:setSessionId);
                        break;
                }

                var cx = new ArenaConfig.Context(getter, setter);
                _cxs.put(dataType, cx);

                return cx;
            }

            class ArenaImpl {
                private var _width as Number = 0;
                private var _height as Number = 0;
                private var _cx as Number = 0;
                private var _cy as Number = 0;
                private var _currentShadowData as ApiSchema.ShadowDataPayload? =
                    null;
                private var _lastError as String? = null;
                private var _sessionId as String = "";

                function getDisplayWidth() as Number {
                    return _width;
                }
                function setDisplayWidth(w as Number) as Void {
                    _width = w;
                }

                function getDisplayHeight() as Number {
                    return _height;
                }
                function setDisplayHeight(h as Number) as Void {
                    _height = h;
                }

                function getCenterX() as Number {
                    return _cx;
                }
                function setCenterX(cx as Number) as Void {
                    _cx = cx;
                }

                function getCenterY() as Number {
                    return _cy;
                }
                function setCenterY(cy as Number) as Void {
                    _cy = cy;
                }

                function getCurrentShadowData() as
                    ApiSchema.ShadowDataPayload? {
                    return _currentShadowData;
                }
                function setCurrentShadowData(
                    data as ApiSchema.ShadowDataPayload
                ) as Void {
                    _currentShadowData = data;
                }

                function getLastError() as String? {
                    return _lastError;
                }
                function setLastError(err as String?) as Void {
                    _lastError = err;
                }

                function getSessionId() as String {
                    return _sessionId;
                }
                function setSessionId(id as String) as Void {
                    _sessionId = id;
                }
            }
        }
    }
}
