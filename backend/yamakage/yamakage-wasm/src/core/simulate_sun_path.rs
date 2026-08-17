use crate::{
    core::{
        azimuth_profile::TerrainAzimuthProfileWasm,
        constants::{
            FULL_CIRCLE_DEG, MS_PER_MINUTE, MS_PER_SECOND, SUN_APPARENT_RADIUS_DEG,
            SUN_STANDARD_HORIZON_ELEVATION_DEG,
        },
        sun_calc::get_sun_position,
    },
    schemas::{calculation_context::CalculationContext, shadow_result::ShadowResultWasm},
};

#[derive(Clone, Debug)]
pub struct SunPathPointWasm {
    pub time: f64,
    pub azimuth: f64,
    pub altitude: f64,
}

pub(crate) fn get_interpolated_angle(profiles: &[TerrainAzimuthProfileWasm], azimuth: f64) -> f64 {
    if profiles.is_empty() {
        return SUN_STANDARD_HORIZON_ELEVATION_DEG;
    }
    if profiles.len() == 1 {
        return profiles[0].max_obstacle_angle_deg;
    }

    let idx = profiles.partition_point(|p| p.azimuth_deg <= azimuth);
    let right_idx = if idx == profiles.len() { 0 } else { idx };

    let left = if right_idx == 0 {
        &profiles[profiles.len() - 1]
    } else {
        &profiles[right_idx - 1]
    };
    let right = if right_idx == 0 {
        &profiles[0]
    } else {
        &profiles[right_idx]
    };

    if left.azimuth_deg == right.azimuth_deg {
        return left.max_obstacle_angle_deg;
    }

    let diff_rl = (right.azimuth_deg - left.azimuth_deg + FULL_CIRCLE_DEG) % FULL_CIRCLE_DEG;
    let diff_al = (azimuth - left.azimuth_deg + FULL_CIRCLE_DEG) % FULL_CIRCLE_DEG;
    let ratio = diff_al / diff_rl;

    left.max_obstacle_angle_deg
        + ratio * (right.max_obstacle_angle_deg - left.max_obstacle_angle_deg)
}

#[derive(Debug, Clone)]
pub(crate) struct SimulationState {
    pub sunset_minutes: f64,
    pub sunset_time_unix: f64,
    pub sunrise_minutes: f64,
    pub sunrise_time_unix: f64,
    pub prev_alt: f64,
    pub prev_obs: f64,
    pub sun_path: Vec<SunPathPointWasm>,
}

impl SimulationState {
    pub fn new(initial_alt: f64, initial_obs: f64) -> Self {
        Self {
            sunset_minutes: 0.0,
            sunset_time_unix: -1.0,
            sunrise_minutes: 0.0,
            sunrise_time_unix: -1.0,
            prev_alt: initial_alt,
            prev_obs: initial_obs,
            sun_path: Vec::new(),
        }
    }
}

/// 太陽の上端が地形の仰角を下回った（日没）か判定する
pub(crate) fn is_sunset(
    prev_sun_alt: f64,
    prev_obs: f64,
    curr_sun_alt: f64,
    curr_obs: f64,
) -> bool {
    let prev_sun_top = prev_sun_alt + SUN_APPARENT_RADIUS_DEG;
    let curr_sun_top = curr_sun_alt + SUN_APPARENT_RADIUS_DEG;
    prev_sun_top >= prev_obs && curr_sun_top < curr_obs
}

/// 太陽の上端が地形の仰角を上回った（日の出）か判定する
pub(crate) fn is_sunrise(
    prev_sun_alt: f64,
    prev_obs: f64,
    curr_sun_alt: f64,
    curr_obs: f64,
) -> bool {
    let prev_sun_top = prev_sun_alt + SUN_APPARENT_RADIUS_DEG;
    let curr_sun_top = curr_sun_alt + SUN_APPARENT_RADIUS_DEG;
    prev_sun_top <= prev_obs && curr_sun_top > curr_obs
}

/// 軌道情報を記録すべきタイミングか判定する
pub(crate) fn should_record_sun_path(
    minute_offset: i32,
    interval_minutes: i32,
    sun_alt: f64,
) -> bool {
    minute_offset % interval_minutes == 0
        && (-720..=720).contains(&minute_offset)
        && sun_alt > -15.0
}

/// 1分（1ステップ）ごとの状態更新を行う純粋関数
pub(crate) fn step_simulation(
    mut state: SimulationState,
    minute_offset: i32,
    current_ms: f64,
    curr_sun_alt: f64,
    curr_sun_azimuth: f64,
    curr_obs: f64,
    path_record_interval: i32,
) -> SimulationState {
    let current_unix = (current_ms / MS_PER_SECOND).floor();

    // 日没判定 (正の時間帯のみ、初回のみ記録)
    if minute_offset > 0 && state.sunset_time_unix < 0.0 {
        if is_sunset(state.prev_alt, state.prev_obs, curr_sun_alt, curr_obs) {
            state.sunset_minutes = minute_offset as f64;
            state.sunset_time_unix = current_unix;
        }
    }

    // 日の出判定 (正の時間帯のみ、初回のみ記録)
    if minute_offset > 0 && state.sunrise_time_unix < 0.0 {
        if is_sunrise(state.prev_alt, state.prev_obs, curr_sun_alt, curr_obs) {
            state.sunrise_minutes = minute_offset as f64;
            state.sunrise_time_unix = current_unix;
        }
    }

    // 軌道情報の記録
    if should_record_sun_path(minute_offset, path_record_interval, curr_sun_alt) {
        state.sun_path.push(SunPathPointWasm {
            time: current_unix,
            azimuth: curr_sun_azimuth,
            altitude: curr_sun_alt,
        });
    }

    state.prev_alt = curr_sun_alt;
    state.prev_obs = curr_obs;

    state
}

pub fn simulate_sun_path(
    ctx: &CalculationContext,
    profiles: &[TerrainAzimuthProfileWasm],
) -> ShadowResultWasm {
    let initial_sun = get_sun_position(ctx.target_time_ms, ctx.lat, ctx.lng);
    let initial_obs = get_interpolated_angle(profiles, initial_sun.azimuth_deg);

    let initial_state = SimulationState::new(initial_sun.altitude_deg, initial_obs);

    const SIMULATION_START_MINUTES: i32 = -720;
    const SIMULATION_END_MINUTES: i32 = 2880;
    const PATH_RECORD_INTERVAL_MINUTES: i32 = 10;

    let final_state = (SIMULATION_START_MINUTES..=SIMULATION_END_MINUTES).fold(
        initial_state,
        |state, minute_offset| {
            let current_ms = ctx.target_time_ms + (minute_offset as f64) * MS_PER_MINUTE;
            let sun_pos = get_sun_position(current_ms, ctx.lat, ctx.lng);
            let obs = get_interpolated_angle(profiles, sun_pos.azimuth_deg);

            // ロジックはすべて切り出した純粋関数に委譲
            step_simulation(
                state,
                minute_offset,
                current_ms,
                sun_pos.altitude_deg,
                sun_pos.azimuth_deg,
                obs,
                PATH_RECORD_INTERVAL_MINUTES,
            )
        },
    );

    let is_polar = final_state.sunset_time_unix < 0.0 && final_state.sunrise_time_unix < 0.0;

    ShadowResultWasm {
        is_polar,
        sunset_time_unix: final_state.sunset_time_unix,
        minutes_to_sunset: final_state.sunset_minutes,
        sunrise_time_unix: final_state.sunrise_time_unix,
        minutes_to_sunrise: final_state.sunrise_minutes,
        azimuth_profiles: profiles.to_vec(),
        sun_path: final_state.sun_path,
    }
}
