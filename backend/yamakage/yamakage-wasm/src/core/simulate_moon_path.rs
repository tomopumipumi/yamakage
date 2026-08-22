use crate::{
    core::{
        azimuth_profile::TerrainAzimuthProfileWasm,
        constants::MS_PER_MINUTE,
        moon_calc::{get_moon_illumination, get_moon_position},
        simulate_sun_path::{SimulationState, get_interpolated_angle, step_simulation},
    },
    schemas::{calculation_context::CalculationContext, moon_shadow_result::MoonShadowResultWasm},
};

pub fn simulate_moon_path(
    ctx: &CalculationContext,
    profiles: &[TerrainAzimuthProfileWasm],
) -> MoonShadowResultWasm {
    let initial_moon = get_moon_position(ctx.target_time_ms, ctx.lat, ctx.lng);
    let initial_obs = get_interpolated_angle(profiles, initial_moon.azimuth_deg);
    let initial_state = SimulationState::new(initial_moon.altitude_deg, initial_obs);

    const SIMULATION_START_MINUTES: i32 = -720;
    const SIMULATION_END_MINUTES: i32 = 2880;
    const PATH_RECORD_INTERVAL_MINUTES: i32 = 10;

    let final_state = (SIMULATION_START_MINUTES..=SIMULATION_END_MINUTES).fold(
        initial_state,
        |state, minute_offset| {
            let current_ms = ctx.target_time_ms + (minute_offset as f64) * MS_PER_MINUTE;
            let pos = get_moon_position(current_ms, ctx.lat, ctx.lng);
            let obs = get_interpolated_angle(profiles, pos.azimuth_deg);

            step_simulation(
                state,
                minute_offset,
                current_ms,
                pos.altitude_deg,
                pos.azimuth_deg,
                obs,
                PATH_RECORD_INTERVAL_MINUTES,
            )
        },
    );

    let is_polar = final_state.sunset_time_unix < 0.0 && final_state.sunrise_time_unix < 0.0;
    let ill = get_moon_illumination(ctx.target_time_ms);

    MoonShadowResultWasm {
        is_polar,
        moonset_time_unix: final_state.sunset_time_unix,
        minutes_to_moonset: final_state.sunset_minutes,
        moonrise_time_unix: final_state.sunrise_time_unix,
        minutes_to_moonrise: final_state.sunrise_minutes,
        azimuth_profiles: profiles.to_vec(),
        moon_path: final_state.sun_path,
        fraction: ill.fraction,
        phase: ill.phase,
    }
}
