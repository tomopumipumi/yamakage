/* tslint:disable */
/* eslint-disable */

/**
 * The main WebAssembly engine for calculating terrain shadows and sun paths.
 * Manages memory buffers for efficient zero-copy data transfer between JavaScript and Wasm.
 *
 * 地形による影と太陽軌道を計算するためのメインWebAssemblyエンジン。
 * JavaScriptとWasm間の効率的なゼロコピーデータ転送のためのメモリバッファを管理します。
 */
export class ShadowEngine {
    free(): void;
    [Symbol.dispose](): void;
    calculate_moon_shadow(lat: number, lng: number, target_time_ms: number, current_altitude: number): number;
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
     */
    calculate_shadow(lat: number, lng: number, target_time_ms: number, current_altitude: number): number;
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
     */
    decode_tile_elevations(png_size: number, num_points: number): boolean;
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
     */
    generate_sampling_points(start_lat: number, start_lng: number, step_deg: number, quality: number): number;
    /**
     * Returns the evaluated elevation of the center (starting) point.
     * 評価された中心（開始）地点の標高を返します。
     */
    get_center_elevation(): number;
    /**
     * Returns the evaluated elevation at the specified arena index.
     * 指定されたアリーナインデックスの評価された標高を返します。
     */
    get_elevation_at(index: number): number;
    /**
     * Returns a mutable pointer to the elevations buffer in Wasm memory.
     * Wasmメモリ内の標高バッファへの可変ポインタを返します。
     */
    get_elevations_ptr(): number;
    /**
     * Resizes the internal u32 I/O buffer and returns its mutable pointer.
     * Used to efficiently transfer pixel coordinates mapped to JS points.
     *
     * 内部のu32 I/Oバッファをリサイズし、その可変ポインタを返します。
     * JS側のポイントにマッピングされたピクセル座標を効率的に転送するために使用されます。
     */
    get_io_u32_ptr(size: number): number;
    /**
     * Resizes the internal u8 I/O buffer and returns its mutable pointer.
     * Used to efficiently transfer PNG tile bytes from JS to Wasm.
     *
     * 内部のu8 I/Oバッファをリサイズし、その可変ポインタを返します。
     * JSからWasmへPNGタイルのバイト列を効率的に転送するために使用されます。
     */
    get_io_u8_ptr(size: number): number;
    /**
     * Returns a constant pointer to the latitudes buffer in Wasm memory.
     * Wasmメモリ内の緯度バッファへの定数ポインタを返します。
     */
    get_lats_ptr(): number;
    /**
     * Returns a constant pointer to the longitudes buffer in Wasm memory.
     * Wasmメモリ内の経度バッファへの定数ポインタを返します。
     */
    get_lngs_ptr(): number;
    /**
     * Initializes a new instance of the ShadowEngine.
     * ShadowEngineの新しいインスタンスを初期化します。
     */
    constructor();
}

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
    readonly memory: WebAssembly.Memory;
    readonly __wbg_shadowengine_free: (a: number, b: number) => void;
    readonly shadowengine_calculate_moon_shadow: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly shadowengine_calculate_shadow: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly shadowengine_decode_tile_elevations: (a: number, b: number, c: number) => number;
    readonly shadowengine_generate_sampling_points: (a: number, b: number, c: number, d: number, e: number) => number;
    readonly shadowengine_get_center_elevation: (a: number) => number;
    readonly shadowengine_get_elevation_at: (a: number, b: number) => number;
    readonly shadowengine_get_elevations_ptr: (a: number) => number;
    readonly shadowengine_get_io_u32_ptr: (a: number, b: number) => number;
    readonly shadowengine_get_io_u8_ptr: (a: number, b: number) => number;
    readonly shadowengine_get_lats_ptr: (a: number) => number;
    readonly shadowengine_get_lngs_ptr: (a: number) => number;
    readonly shadowengine_new: () => number;
    readonly __wbindgen_externrefs: WebAssembly.Table;
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
