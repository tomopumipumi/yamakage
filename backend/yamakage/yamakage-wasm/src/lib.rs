mod arena;
mod engine;
mod sun_calc;
mod types;

use arena::SamplingArena;
use types::CalculationContext;
use wasm_bindgen::prelude::*;

use crate::types::EngineError;

#[wasm_bindgen]
pub struct ShadowEngine {
    arena: SamplingArena,
}

#[wasm_bindgen]
impl ShadowEngine {
    #[wasm_bindgen(constructor)]
    pub fn new() -> ShadowEngine {
        ShadowEngine {
            arena: SamplingArena::new(),
        }
    }

    pub fn generate_sampling_points(
        &mut self,
        start_lat: f64,
        start_lng: f64,
        step_deg: f64,
        quality: u8,
    ) -> usize {
        engine::generate_sampling_points(&mut self.arena, start_lat, start_lng, step_deg, quality);
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

    pub fn calculate_shadow(
        &self,
        lat: f64,
        lng: f64,
        target_time_ms: f64,
        current_altitude: f64,
    ) -> Result<JsValue, JsError> {
        let ctx = CalculationContext::try_new(lat, lng, target_time_ms, current_altitude)
            .map_err(|e| JsError::new(&e.to_string()))?;

        let profiles = engine::calculate_azimuth_profiles(&self.arena, ctx.eye_level_altitude);

        let result = engine::simulate_sun_path(&ctx, &profiles);

        serde_wasm_bindgen::to_value(&result)
            .map_err(|e| JsError::new(&EngineError::SerializationFailed(e.to_string()).to_string()))
    }
}
