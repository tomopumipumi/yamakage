/* @ts-self-types="./yamakage_wasm.d.ts" */

/**
 * The main WebAssembly engine for calculating terrain shadows and sun paths.
 * Manages memory buffers for efficient zero-copy data transfer between JavaScript and Wasm.
 *
 * 地形による影と太陽軌道を計算するためのメインWebAssemblyエンジン。
 * JavaScriptとWasm間の効率的なゼロコピーデータ転送のためのメモリバッファを管理します。
 */
export class ShadowEngine {
    __destroy_into_raw() {
        const ptr = this.__wbg_ptr;
        this.__wbg_ptr = 0;
        ShadowEngineFinalization.unregister(this);
        return ptr;
    }
    free() {
        const ptr = this.__destroy_into_raw();
        wasm.__wbg_shadowengine_free(ptr, 0);
    }
    /**
     * @param {number} lat
     * @param {number} lng
     * @param {number} target_time_ms
     * @param {number} current_altitude
     * @returns {number}
     */
    calculate_moon_shadow(lat, lng, target_time_ms, current_altitude) {
        const ret = wasm.shadowengine_calculate_moon_shadow(this.__wbg_ptr, lat, lng, target_time_ms, current_altitude);
        return ret >>> 0;
    }
    /**
     * Executes the core shadow and sun path calculations based on the decoded terrain data.
     * デコードされた地形データに基づき、影と太陽軌道のコア計算を実行します。
     *
     * # Arguments
     * * `lat` - Target latitude / ターゲットの緯度
     * * `lng` - Target longitude / ターゲットの経度
     * * `target_time_ms` - Target Unix timestamp in milliseconds / ターゲットのUnixタイムスタンプ(ミリ秒)
     * * `current_altitude` - Target altitude in meters / ターゲットの標高(メートル)
     *
     * # Returns
     * A constant pointer to the result buffer containing serialized f64 values (ShadowResultWasm).
     * シリアライズされたf64値（ShadowResultWasm）を含む結果バッファへの定数ポインタを返します。
     * @param {number} lat
     * @param {number} lng
     * @param {number} target_time_ms
     * @param {number} current_altitude
     * @returns {number}
     */
    calculate_shadow(lat, lng, target_time_ms, current_altitude) {
        const ret = wasm.shadowengine_calculate_shadow(this.__wbg_ptr, lat, lng, target_time_ms, current_altitude);
        return ret >>> 0;
    }
    /**
     * Decodes elevation data from the PNG tile loaded into the I/O buffer and stores it in the arena.
     * I/Oバッファに読み込まれたPNGタイルから標高データをデコードし、アリーナに保存します。
     *
     * # Arguments
     * * `png_size` - Size of the PNG data in bytes / PNGデータのバイトサイズ
     * * `num_points` - Number of coordinate points to decode from this tile / デコードする座標ポイントの数
     *
     * # Returns
     * `true` if decoding was successful, `false` otherwise.
     * デコードに成功した場合は `true`、それ以外は `false` を返します。
     * @param {number} png_size
     * @param {number} num_points
     * @returns {boolean}
     */
    decode_tile_elevations(png_size, num_points) {
        const ret = wasm.shadowengine_decode_tile_elevations(this.__wbg_ptr, png_size, num_points);
        return ret !== 0;
    }
    /**
     * Generates geographic sampling points around the starting coordinate based on the specified step angle and quality.
     * 指定されたステップ角と品質に基づき、開始座標の周囲に地理的なサンプリングポイントを生成します。
     *
     * # Arguments
     * * `start_lat` - Starting latitude / 出発点の緯度
     * * `start_lng` - Starting longitude / 出発点の経度
     * * `step_deg` - Angle interval in degrees / 方位角の間隔（度）
     * * `quality` - Quality level (determines distance and density) / 品質レベル（距離と密度を決定）
     *
     * # Returns
     * The total number of generated sampling points.
     * 生成されたサンプリングポイントの総数を返します。
     * @param {number} start_lat
     * @param {number} start_lng
     * @param {number} step_deg
     * @param {number} quality
     * @returns {number}
     */
    generate_sampling_points(start_lat, start_lng, step_deg, quality) {
        const ret = wasm.shadowengine_generate_sampling_points(this.__wbg_ptr, start_lat, start_lng, step_deg, quality);
        return ret >>> 0;
    }
    /**
     * Returns the evaluated elevation of the center (starting) point.
     * 評価された中心（開始）地点の標高を返します。
     * @returns {number}
     */
    get_center_elevation() {
        const ret = wasm.shadowengine_get_center_elevation(this.__wbg_ptr);
        return ret;
    }
    /**
     * Returns the evaluated elevation at the specified arena index.
     * 指定されたアリーナインデックスの評価された標高を返します。
     * @param {number} index
     * @returns {number}
     */
    get_elevation_at(index) {
        const ret = wasm.shadowengine_get_elevation_at(this.__wbg_ptr, index);
        return ret;
    }
    /**
     * Returns a mutable pointer to the elevations buffer in Wasm memory.
     * Wasmメモリ内の標高バッファへの可変ポインタを返します。
     * @returns {number}
     */
    get_elevations_ptr() {
        const ret = wasm.shadowengine_get_elevations_ptr(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Resizes the internal u32 I/O buffer and returns its mutable pointer.
     * Used to efficiently transfer pixel coordinates mapped to JS points.
     *
     * 内部のu32 I/Oバッファをリサイズし、その可変ポインタを返します。
     * JS側のポイントにマッピングされたピクセル座標を効率的に転送するために使用されます。
     * @param {number} size
     * @returns {number}
     */
    get_io_u32_ptr(size) {
        const ret = wasm.shadowengine_get_io_u32_ptr(this.__wbg_ptr, size);
        return ret >>> 0;
    }
    /**
     * Resizes the internal u8 I/O buffer and returns its mutable pointer.
     * Used to efficiently transfer PNG tile bytes from JS to Wasm.
     *
     * 内部のu8 I/Oバッファをリサイズし、その可変ポインタを返します。
     * JSからWasmへPNGタイルのバイト列を効率的に転送するために使用されます。
     * @param {number} size
     * @returns {number}
     */
    get_io_u8_ptr(size) {
        const ret = wasm.shadowengine_get_io_u8_ptr(this.__wbg_ptr, size);
        return ret >>> 0;
    }
    /**
     * Returns a constant pointer to the latitudes buffer in Wasm memory.
     * Wasmメモリ内の緯度バッファへの定数ポインタを返します。
     * @returns {number}
     */
    get_lats_ptr() {
        const ret = wasm.shadowengine_get_lats_ptr(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Returns a constant pointer to the longitudes buffer in Wasm memory.
     * Wasmメモリ内の経度バッファへの定数ポインタを返します。
     * @returns {number}
     */
    get_lngs_ptr() {
        const ret = wasm.shadowengine_get_lngs_ptr(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * Initializes a new instance of the ShadowEngine.
     * ShadowEngineの新しいインスタンスを初期化します。
     */
    constructor() {
        const ret = wasm.shadowengine_new();
        this.__wbg_ptr = ret;
        ShadowEngineFinalization.register(this, this.__wbg_ptr, this);
        return this;
    }
}
if (Symbol.dispose) ShadowEngine.prototype[Symbol.dispose] = ShadowEngine.prototype.free;
function __wbg_get_imports() {
    const import0 = {
        __proto__: null,
        __wbg___wbindgen_throw_bb96b2010945f0bc: function(arg0, arg1) {
            throw new Error(getStringFromWasm0(arg0, arg1));
        },
        __wbindgen_init_externref_table: function() {
            const table = wasm.__wbindgen_externrefs;
            const offset = table.grow(4);
            table.set(0, undefined);
            table.set(offset + 0, undefined);
            table.set(offset + 1, null);
            table.set(offset + 2, true);
            table.set(offset + 3, false);
        },
    };
    return {
        __proto__: null,
        "./yamakage_wasm_bg.js": import0,
    };
}

const ShadowEngineFinalization = (typeof FinalizationRegistry === 'undefined')
    ? { register: () => {}, unregister: () => {} }
    : new FinalizationRegistry(ptr => wasm.__wbg_shadowengine_free(ptr, 1));

function getStringFromWasm0(ptr, len) {
    return decodeText(ptr >>> 0, len);
}

let cachedUint8ArrayMemory0 = null;
function getUint8ArrayMemory0() {
    if (cachedUint8ArrayMemory0 === null || cachedUint8ArrayMemory0.byteLength === 0) {
        cachedUint8ArrayMemory0 = new Uint8Array(wasm.memory.buffer);
    }
    return cachedUint8ArrayMemory0;
}

let cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
cachedTextDecoder.decode();
const MAX_SAFARI_DECODE_BYTES = 2146435072;
let numBytesDecoded = 0;
function decodeText(ptr, len) {
    numBytesDecoded += len;
    if (numBytesDecoded >= MAX_SAFARI_DECODE_BYTES) {
        cachedTextDecoder = new TextDecoder('utf-8', { ignoreBOM: true, fatal: true });
        cachedTextDecoder.decode();
        numBytesDecoded = len;
    }
    return cachedTextDecoder.decode(getUint8ArrayMemory0().subarray(ptr, ptr + len));
}

let wasmModule, wasmInstance, wasm;
function __wbg_finalize_init(instance, module) {
    wasmInstance = instance;
    wasm = instance.exports;
    wasmModule = module;
    cachedUint8ArrayMemory0 = null;
    wasm.__wbindgen_start();
    return wasm;
}

async function __wbg_load(module, imports) {
    if (typeof Response === 'function' && module instanceof Response) {
        if (!module.ok) {
            throw new Error(`failed to fetch Wasm: ${module.status} ${module.statusText} fetching '${module.url}'`);
        }

        if (typeof WebAssembly.instantiateStreaming === 'function') {
            try {
                return await WebAssembly.instantiateStreaming(module, imports);
            } catch (e) {
                const validResponse = expectedResponseType(module.type);

                if (validResponse && module.headers.get('Content-Type') !== 'application/wasm') {
                    console.warn("`WebAssembly.instantiateStreaming` failed because your server does not serve Wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n", e);

                } else { throw e; }
            }
        }

        const bytes = await module.arrayBuffer();
        return await WebAssembly.instantiate(bytes, imports);
    } else {
        const instance = await WebAssembly.instantiate(module, imports);

        if (instance instanceof WebAssembly.Instance) {
            return { instance, module };
        } else {
            return instance;
        }
    }

    function expectedResponseType(type) {
        switch (type) {
            case 'basic': case 'cors': case 'default': return true;
        }
        return false;
    }
}

function initSync(module) {
    if (wasm !== undefined) return wasm;


    if (module !== undefined) {
        if (Object.getPrototypeOf(module) === Object.prototype) {
            ({module} = module)
        } else {
            console.warn('using deprecated parameters for `initSync()`; pass a single object instead')
        }
    }

    const imports = __wbg_get_imports();
    if (!(module instanceof WebAssembly.Module)) {
        module = new WebAssembly.Module(module);
    }
    const instance = new WebAssembly.Instance(module, imports);
    return __wbg_finalize_init(instance, module);
}

async function __wbg_init(module_or_path) {
    if (wasm !== undefined) return wasm;


    if (module_or_path !== undefined) {
        if (Object.getPrototypeOf(module_or_path) === Object.prototype) {
            ({module_or_path} = module_or_path)
        } else {
            console.warn('using deprecated parameters for the initialization function; pass a single object instead')
        }
    }

    if (module_or_path === undefined) {
        module_or_path = new URL('yamakage_wasm_bg.wasm', import.meta.url);
    }
    const imports = __wbg_get_imports();

    if (typeof module_or_path === 'string' || (typeof Request === 'function' && module_or_path instanceof Request) || (typeof URL === 'function' && module_or_path instanceof URL)) {
        module_or_path = fetch(module_or_path);
    }

    const { instance, module } = await __wbg_load(await module_or_path, imports);

    return __wbg_finalize_init(instance, module);
}

export { initSync, __wbg_init as default };
