/* tslint:disable */
/* eslint-disable */

export class ShadowEngine {
    free(): void;
    [Symbol.dispose](): void;
    calculate_shadow(lat: number, lng: number, target_time_ms: number, current_altitude: number): any;
    generate_sampling_points(start_lat: number, start_lng: number, step_deg: number, quality: number): number;
    get_elevations_ptr(): number;
    get_lats_ptr(): number;
    get_lngs_ptr(): number;
    constructor();
}

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
    readonly memory: WebAssembly.Memory;
    readonly __wbg_shadowengine_free: (a: number, b: number) => void;
    readonly shadowengine_calculate_shadow: (a: number, b: number, c: number, d: number, e: number) => [number, number, number];
    readonly shadowengine_generate_sampling_points: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly shadowengine_get_elevations_ptr: (a: number) => number;
    readonly shadowengine_get_lats_ptr: (a: number) => number;
    readonly shadowengine_get_lngs_ptr: (a: number) => number;
    readonly shadowengine_new: () => number;
    readonly __wbindgen_malloc: (a: number, b: number) => number;
    readonly __wbindgen_realloc: (a: number, b: number, c: number, d: number) => number;
    readonly __wbindgen_externrefs: WebAssembly.Table;
    readonly __externref_table_dealloc: (a: number) => void;
    readonly __wbindgen_start: () => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;

/**
 * Instantiates the given `module`, which can either be bytes or
 * a precompiled `WebAssembly.Module`.
 *
 * @param {{ module: SyncInitInput }} module - Passing `SyncInitInput` directly is deprecated.
 *
 * @returns {InitOutput}
 */
export function initSync(module: { module: SyncInitInput } | SyncInitInput): InitOutput;

/**
 * If `module_or_path` is {RequestInfo} or {URL}, makes a request and
 * for everything else, calls `WebAssembly.instantiate` directly.
 *
 * @param {{ module_or_path: InitInput | Promise<InitInput> }} module_or_path - Passing `InitInput` directly is deprecated.
 *
 * @returns {Promise<InitOutput>}
 */
export default function __wbg_init (module_or_path?: { module_or_path: InitInput | Promise<InitInput> } | InitInput | Promise<InitInput>): Promise<InitOutput>;
