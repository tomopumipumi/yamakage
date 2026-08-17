mod core;
mod io;
mod memory;
mod schemas;

use wasm_bindgen::prelude::*;

use core::{azimuth_profile, simulate_sun_path, terrain_sampling};
use io::tile_decoder;
use memory::arena::SamplingArena;

use crate::schemas::calculation_context::CalculationContext;

/// The main WebAssembly engine for calculating terrain shadows and sun paths.
/// Manages memory buffers for efficient zero-copy data transfer between JavaScript and Wasm.
///
/// 地形による影と太陽軌道を計算するためのメインWebAssemblyエンジン。
/// JavaScriptとWasm間の効率的なゼロコピーデータ転送のためのメモリバッファを管理します。
#[wasm_bindgen]
pub struct ShadowEngine {
    /// Arena for storing sampling points, distances, and elevations.
    /// サンプリングポイント、距離、標高を格納するアリーナ。
    arena: SamplingArena,

    /// Buffer for storing the serialized final calculation results (f64 array).
    /// シリアライズされた最終計算結果（f64配列）を格納するバッファ。
    result_buffer: Vec<f64>,

    /// I/O buffer for passing raw byte data (e.g., PNG tile bytes) from JS.
    /// JSから生バイトデータ（PNGタイルのバイト列など）を渡すためのI/Oバッファ。
    io_u8_buffer: Vec<u8>,

    /// I/O buffer for passing 32-bit integer data (e.g., pixel coordinates) from JS.
    /// JSから32ビット整数データ（ピクセル座標など）を渡すためのI/Oバッファ。
    io_u32_buffer: Vec<u32>,

    /// The decoded elevation of the starting (center) location.
    /// デコードされた出発点（中心点）の標高。
    center_elevation: f64,
}

#[wasm_bindgen]
impl ShadowEngine {
    /// Initializes a new instance of the ShadowEngine.
    /// ShadowEngineの新しいインスタンスを初期化します。
    #[wasm_bindgen(constructor)]
    pub fn new() -> ShadowEngine {
        ShadowEngine {
            arena: SamplingArena::new(),
            result_buffer: Vec::with_capacity(2048),
            io_u8_buffer: Vec::new(),
            io_u32_buffer: Vec::new(),
            center_elevation: 0.0,
        }
    }

    /// Generates geographic sampling points around the starting coordinate based on the specified step angle and quality.
    /// 指定されたステップ角と品質に基づき、開始座標の周囲に地理的なサンプリングポイントを生成します。
    ///
    /// # Arguments
    /// * `start_lat` - Starting latitude / 出発点の緯度
    /// * `start_lng` - Starting longitude / 出発点の経度
    /// * `step_deg` - Angle interval in degrees / 方位角の間隔（度）
    /// * `quality` - Quality level (determines distance and density) / 品質レベル（距離と密度を決定）
    ///
    /// # Returns
    /// The total number of generated sampling points.
    /// 生成されたサンプリングポイントの総数を返します。
    pub fn generate_sampling_points(
        &mut self,
        start_lat: f64,
        start_lng: f64,
        step_deg: f64,
        quality: u8,
    ) -> usize {
        terrain_sampling::generate_sampling_points(
            &mut self.arena,
            start_lat,
            start_lng,
            step_deg,
            quality,
        );
        self.arena.lats.len()
    }

    /// Returns a constant pointer to the latitudes buffer in Wasm memory.
    /// Wasmメモリ内の緯度バッファへの定数ポインタを返します。
    pub fn get_lats_ptr(&self) -> *const f64 {
        self.arena.lats.as_ptr()
    }

    /// Returns a constant pointer to the longitudes buffer in Wasm memory.
    /// Wasmメモリ内の経度バッファへの定数ポインタを返します。
    pub fn get_lngs_ptr(&self) -> *const f64 {
        self.arena.lngs.as_ptr()
    }

    /// Returns a mutable pointer to the elevations buffer in Wasm memory.
    /// Wasmメモリ内の標高バッファへの可変ポインタを返します。
    pub fn get_elevations_ptr(&mut self) -> *mut f64 {
        self.arena.elevations.as_mut_ptr()
    }

    /// Resizes the internal u8 I/O buffer and returns its mutable pointer.
    /// Used to efficiently transfer PNG tile bytes from JS to Wasm.
    ///
    /// 内部のu8 I/Oバッファをリサイズし、その可変ポインタを返します。
    /// JSからWasmへPNGタイルのバイト列を効率的に転送するために使用されます。
    pub fn get_io_u8_ptr(&mut self, size: usize) -> *mut u8 {
        self.io_u8_buffer.resize(size, 0);
        self.io_u8_buffer.as_mut_ptr()
    }

    /// Resizes the internal u32 I/O buffer and returns its mutable pointer.
    /// Used to efficiently transfer pixel coordinates mapped to JS points.
    ///
    /// 内部のu32 I/Oバッファをリサイズし、その可変ポインタを返します。
    /// JS側のポイントにマッピングされたピクセル座標を効率的に転送するために使用されます。
    pub fn get_io_u32_ptr(&mut self, size: usize) -> *mut u32 {
        self.io_u32_buffer.resize(size, 0);
        self.io_u32_buffer.as_mut_ptr()
    }

    /// Returns the evaluated elevation of the center (starting) point.
    /// 評価された中心（開始）地点の標高を返します。
    pub fn get_center_elevation(&self) -> f64 {
        self.center_elevation
    }

    /// Returns the evaluated elevation at the specified arena index.
    /// 指定されたアリーナインデックスの評価された標高を返します。
    pub fn get_elevation_at(&self, index: usize) -> f64 {
        self.arena.elevations.get(index).copied().unwrap_or(0.0)
    }

    /// Decodes elevation data from the PNG tile loaded into the I/O buffer and stores it in the arena.
    /// I/Oバッファに読み込まれたPNGタイルから標高データをデコードし、アリーナに保存します。
    ///
    /// # Arguments
    /// * `png_size` - Size of the PNG data in bytes / PNGデータのバイトサイズ
    /// * `num_points` - Number of coordinate points to decode from this tile / デコードする座標ポイントの数
    ///
    /// # Returns
    /// `true` if decoding was successful, `false` otherwise.
    /// デコードに成功した場合は `true`、それ以外は `false` を返します。
    pub fn decode_tile_elevations(&mut self, png_size: usize, num_points: usize) -> bool {
        tile_decoder::decode_and_store_elevations(
            &self.io_u8_buffer[..png_size],
            &self.io_u32_buffer[..num_points * 3],
            num_points,
            &mut self.arena,
            &mut self.center_elevation,
        )
    }

    /// Executes the core shadow and sun path calculations based on the decoded terrain data.
    /// デコードされた地形データに基づき、影と太陽軌道のコア計算を実行します。
    ///
    /// # Arguments
    /// * `lat` - Target latitude / ターゲットの緯度
    /// * `lng` - Target longitude / ターゲットの経度
    /// * `target_time_ms` - Target Unix timestamp in milliseconds / ターゲットのUnixタイムスタンプ(ミリ秒)
    /// * `current_altitude` - Target altitude in meters / ターゲットの標高(メートル)
    ///
    /// # Returns
    /// A constant pointer to the result buffer containing serialized f64 values (ShadowResultWasm).
    /// シリアライズされたf64値（ShadowResultWasm）を含む結果バッファへの定数ポインタを返します。
    pub fn calculate_shadow(
        &mut self,
        lat: f64,
        lng: f64,
        target_time_ms: f64,
        current_altitude: f64,
    ) -> *const f64 {
        self.result_buffer.clear();

        let ctx = match CalculationContext::try_new(lat, lng, target_time_ms, current_altitude) {
            Ok(c) => c,
            Err(_) => {
                self.result_buffer.push(f64::NAN);
                return self.result_buffer.as_ptr();
            }
        };

        let profiles =
            azimuth_profile::calculate_azimuth_profiles(&self.arena, ctx.eye_level_altitude);
        let result = simulate_sun_path::simulate_sun_path(&ctx, &profiles);

        result.pack_into_buffer(&mut self.result_buffer);

        self.result_buffer.as_ptr()
    }
}
