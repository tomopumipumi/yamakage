use crate::arena::AzimuthGroup;
use crate::arena::SamplingArena;
use crate::sun_calc::get_sun_position;
use crate::types::{
    CalculationContext, CoordinateWasm, ShadowResultWasm, SunPathPointWasm,
    TerrainAzimuthProfileWasm,
};

const RAD: f64 = std::f64::consts::PI / 180.0;
const EARTH_RADIUS: f64 = 6371000.0;
const REFRACTION_COEFF: f64 = 0.86;

struct LineConfig {
    start_dist: f64,
    max_dist: f64,
    interval: f64,
}

fn get_quality_configs(quality: u8) -> &'static [LineConfig] {
    match quality {
        2 => &[
            LineConfig {
                start_dist: 10.0,
                max_dist: 2000.0,
                interval: 30.0,
            },
            LineConfig {
                start_dist: 2090.0,
                max_dist: 10000.0,
                interval: 90.0,
            },
            LineConfig {
                start_dist: 10200.0,
                max_dist: 30000.0,
                interval: 200.0,
            },
        ],
        1 => &[
            LineConfig {
                start_dist: 10.0,
                max_dist: 1000.0,
                interval: 30.0,
            },
            LineConfig {
                start_dist: 1100.0,
                max_dist: 5000.0,
                interval: 100.0,
            },
            LineConfig {
                start_dist: 5100.0,
                max_dist: 15000.0,
                interval: 250.0,
            },
            LineConfig {
                start_dist: 15000.0,
                max_dist: 30000.0,
                interval: 500.0,
            },
        ],
        _ => &[
            LineConfig {
                start_dist: 10.0,
                max_dist: 1000.0,
                interval: 50.0,
            },
            LineConfig {
                start_dist: 1200.0,
                max_dist: 5000.0,
                interval: 200.0,
            },
            LineConfig {
                start_dist: 5500.0,
                max_dist: 30000.0,
                interval: 500.0,
            },
        ],
    }
}

pub fn generate_sampling_points(
    arena: &mut SamplingArena,
    start_lat: f64,
    start_lng: f64,
    step_deg: f64,
    quality: u8,
) {
    arena.clear();
    let configs = get_quality_configs(quality);
    let num_azimuths = (360.0 / step_deg).floor() as usize;

    let start_lat_rad = start_lat * RAD;
    let start_lng_rad = start_lng * RAD;

    let sl_sin = start_lat_rad.sin();
    let sl_cos = start_lat_rad.cos();

    for i in 0..num_azimuths {
        let azimuth_deg = (i as f64) * step_deg;
        let azimuth_rad = azimuth_deg * RAD;

        let az_sin = azimuth_rad.sin();
        let az_cos = azimuth_rad.cos();

        let start_idx = arena.lats.len();

        for config in configs {
            let mut dist = config.start_dist;
            while dist <= config.max_dist {
                let angular_distance = dist / EARTH_RADIUS;
                let ad_sin = angular_distance.sin();
                let ad_cos = angular_distance.cos();

                let lat_rad = (sl_sin * ad_cos + sl_cos * ad_sin * az_cos).asin();
                let lng_rad = start_lng_rad
                    + (az_sin * ad_sin * sl_cos).atan2(ad_cos - sl_sin * lat_rad.sin());

                arena.lats.push(lat_rad / RAD);
                arena.lngs.push(lng_rad / RAD);
                arena.distances.push(dist);

                dist += config.interval;
            }
        }

        let end_idx = arena.lats.len();
        arena.groups.push(AzimuthGroup {
            azimuth_deg,
            range: start_idx..end_idx,
        });
    }

    arena.resize_elevations();
}

pub fn calculate_azimuth_profiles(
    arena: &SamplingArena,
    eye_level_altitude: f64,
) -> Vec<TerrainAzimuthProfileWasm> {
    arena
        .groups
        .iter()
        .map(|group| {
            let range = group.range.clone();

            let max_point = range
                .map(|i| {
                    let alt = arena.elevations[i];
                    let dist = arena.distances[i];
                    let drop = (dist * dist) / (2.0 * EARTH_RADIUS) * REFRACTION_COEFF;
                    let effective_diff = alt - eye_level_altitude - drop;
                    let angle_deg = effective_diff.atan2(dist) / RAD;
                    (angle_deg, arena.lats[i], arena.lngs[i])
                })
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap_or(std::cmp::Ordering::Equal));

            let (max_angle, max_lat, max_lng) = max_point.unwrap_or((-0.833, 0.0, 0.0));
            let angle = max_angle.max(-0.833);

            TerrainAzimuthProfileWasm {
                azimuth_deg: group.azimuth_deg,
                max_obstacle_angle_deg: angle,
                highest_point: if angle > -0.833 {
                    Some(CoordinateWasm {
                        lat: max_lat,
                        lng: max_lng,
                    })
                } else {
                    None
                },
            }
        })
        .collect()
}

fn get_interpolated_angle(profiles: &[TerrainAzimuthProfileWasm], azimuth: f64) -> f64 {
    if profiles.is_empty() {
        return -0.833;
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

    let diff_rl = (right.azimuth_deg - left.azimuth_deg + 360.0) % 360.0;
    let diff_al = (azimuth - left.azimuth_deg + 360.0) % 360.0;
    let ratio = diff_al / diff_rl;

    left.max_obstacle_angle_deg
        + ratio * (right.max_obstacle_angle_deg - left.max_obstacle_angle_deg)
}

pub fn simulate_sun_path(
    ctx: &CalculationContext,
    profiles: &[TerrainAzimuthProfileWasm],
) -> ShadowResultWasm {
    let initial_sun = get_sun_position(ctx.target_time_ms, ctx.lat, ctx.lng);
    let initial_obs = get_interpolated_angle(profiles, initial_sun.azimuth_deg);

    struct SimulationState {
        sunset_minutes: f64,
        sunset_time_unix: f64,
        sunrise_minutes: f64,
        sunrise_time_unix: f64,
        prev_alt: f64,
        prev_obs: f64,
        sun_path: Vec<SunPathPointWasm>,
    }

    let initial_state = SimulationState {
        sunset_minutes: 0.0,
        sunset_time_unix: -1.0,
        sunrise_minutes: 0.0,
        sunrise_time_unix: -1.0,
        prev_alt: initial_sun.altitude_deg,
        prev_obs: initial_obs,
        sun_path: Vec::new(),
    };

    let final_state = (-720..=2880).fold(initial_state, |mut state, i| {
        let current_ms = ctx.target_time_ms + (i as f64) * 60000.0;
        let sun_pos = get_sun_position(current_ms, ctx.lat, ctx.lng);
        let obs = get_interpolated_angle(profiles, sun_pos.azimuth_deg);

        if i > 0
            && state.sunset_time_unix < 0.0
            && state.prev_alt >= state.prev_obs
            && sun_pos.altitude_deg < obs
        {
            state.sunset_minutes = i as f64;
            state.sunset_time_unix = (current_ms / 1000.0).floor();
        }

        if i > 0
            && state.sunrise_time_unix < 0.0
            && state.prev_alt <= state.prev_obs
            && sun_pos.altitude_deg > obs
        {
            state.sunrise_minutes = i as f64;
            state.sunrise_time_unix = (current_ms / 1000.0).floor();
        }

        if i % 10 == 0 && (-720..=720).contains(&i) && sun_pos.altitude_deg > -15.0 {
            state.sun_path.push(SunPathPointWasm {
                time: (current_ms / 1000.0).floor(),
                azimuth: sun_pos.azimuth_deg,
                altitude: sun_pos.altitude_deg,
            });
        }

        state.prev_alt = sun_pos.altitude_deg;
        state.prev_obs = obs;
        state
    });

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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::arena::AzimuthGroup;

    #[test]
    fn test_generate_sampling_points() {
        let mut arena = SamplingArena::new();
        generate_sampling_points(&mut arena, 35.0, 135.0, 90.0, 0);

        assert_eq!(arena.groups.len(), 4); // 360 / 90 = 4 groups
        assert_eq!(arena.elevations.len(), arena.lats.len());
    }

    #[test]
    fn test_calculate_azimuth_profiles() {
        let mut arena = SamplingArena::new();
        arena.lats.push(35.0);
        arena.lngs.push(135.0);
        arena.distances.push(1000.0);
        arena.elevations.push(111.5);
        arena.groups.push(AzimuthGroup {
            azimuth_deg: 90.0,
            range: 0..1,
        });

        let profiles = calculate_azimuth_profiles(&arena, 11.5);
        assert_eq!(profiles.len(), 1);
        assert_eq!(profiles[0].azimuth_deg, 90.0);
        assert!(profiles[0].max_obstacle_angle_deg > 0.0);
    }

    #[test]
    fn test_get_interpolated_angle() {
        let profiles = vec![
            TerrainAzimuthProfileWasm {
                azimuth_deg: 0.0,
                max_obstacle_angle_deg: 10.0,
                highest_point: None,
            },
            TerrainAzimuthProfileWasm {
                azimuth_deg: 180.0,
                max_obstacle_angle_deg: 20.0,
                highest_point: None,
            },
        ];

        let angle = get_interpolated_angle(&profiles, 90.0);
        assert_eq!(angle, 15.0);

        let angle_wrap = get_interpolated_angle(&profiles, 270.0);
        assert_eq!(angle_wrap, 15.0);
    }

    #[test]
    fn test_simulate_sun_path() {
        let ctx = CalculationContext::try_new(35.0, 135.0, 1718000000000.0, 10.0).unwrap();
        let profiles = vec![];

        let result = simulate_sun_path(&ctx, &profiles);
        assert!(!result.is_polar);
        assert!(result.sun_path.len() > 0);
    }
}
