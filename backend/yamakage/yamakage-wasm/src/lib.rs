mod core;
mod io;
mod memory;
mod schemas;

use wasm_bindgen::prelude::*;

use core::{azimuth_profile, simulate_sun_path, terrain_sampling};
use io::tile_decoder;
use memory::arena::SamplingArena;

use crate::schemas::calculation_context::CalculationContext;

#[wasm_bindgen]
pub struct ShadowEngine {
    arena: SamplingArena,
    result_buffer: Vec<f64>,
    io_u8_buffer: Vec<u8>,
    io_u32_buffer: Vec<u32>,
    center_elevation: f64,
}

#[wasm_bindgen]
impl ShadowEngine {
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

    pub fn get_lats_ptr(&self) -> *const f64 {
        self.arena.lats.as_ptr()
    }

    pub fn get_lngs_ptr(&self) -> *const f64 {
        self.arena.lngs.as_ptr()
    }

    pub fn get_elevations_ptr(&mut self) -> *mut f64 {
        self.arena.elevations.as_mut_ptr()
    }

    pub fn get_io_u8_ptr(&mut self, size: usize) -> *mut u8 {
        self.io_u8_buffer.resize(size, 0);
        self.io_u8_buffer.as_mut_ptr()
    }

    pub fn get_io_u32_ptr(&mut self, size: usize) -> *mut u32 {
        self.io_u32_buffer.resize(size, 0);
        self.io_u32_buffer.as_mut_ptr()
    }

    pub fn get_center_elevation(&self) -> f64 {
        self.center_elevation
    }

    pub fn get_elevation_at(&self, index: usize) -> f64 {
        self.arena.elevations.get(index).copied().unwrap_or(0.0)
    }

    pub fn decode_tile_elevations(&mut self, png_size: usize, num_points: usize) -> bool {
        tile_decoder::decode_and_store_elevations(
            &self.io_u8_buffer[..png_size],
            &self.io_u32_buffer[..num_points * 3],
            num_points,
            &mut self.arena,
            &mut self.center_elevation,
        )
    }

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
