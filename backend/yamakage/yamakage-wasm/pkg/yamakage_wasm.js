/* @ts-self-types="./yamakage_wasm.d.ts" */

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
    calculate_shadow(lat, lng, target_time_ms, current_altitude) {
        const ret = wasm.shadowengine_calculate_shadow(this.__wbg_ptr, lat, lng, target_time_ms, current_altitude);
        return ret >>> 0;
    }
    /**
     * @param {number} png_size
     * @param {number} num_points
     * @returns {boolean}
     */
    decode_tile_elevations(png_size, num_points) {
        const ret = wasm.shadowengine_decode_tile_elevations(this.__wbg_ptr, png_size, num_points);
        return ret !== 0;
    }
    /**
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
     * @returns {number}
     */
    get_center_elevation() {
        const ret = wasm.shadowengine_get_center_elevation(this.__wbg_ptr);
        return ret;
    }
    /**
     * @param {number} index
     * @returns {number}
     */
    get_elevation_at(index) {
        const ret = wasm.shadowengine_get_elevation_at(this.__wbg_ptr, index);
        return ret;
    }
    /**
     * @returns {number}
     */
    get_elevations_ptr() {
        const ret = wasm.shadowengine_get_elevations_ptr(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @param {number} size
     * @returns {number}
     */
    get_io_u32_ptr(size) {
        const ret = wasm.shadowengine_get_io_u32_ptr(this.__wbg_ptr, size);
        return ret >>> 0;
    }
    /**
     * @param {number} size
     * @returns {number}
     */
    get_io_u8_ptr(size) {
        const ret = wasm.shadowengine_get_io_u8_ptr(this.__wbg_ptr, size);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get_lats_ptr() {
        const ret = wasm.shadowengine_get_lats_ptr(this.__wbg_ptr);
        return ret >>> 0;
    }
    /**
     * @returns {number}
     */
    get_lngs_ptr() {
        const ret = wasm.shadowengine_get_lngs_ptr(this.__wbg_ptr);
        return ret >>> 0;
    }
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
