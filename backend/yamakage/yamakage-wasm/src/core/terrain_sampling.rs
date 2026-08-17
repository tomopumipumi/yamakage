use crate::{
    core::constants::{
        DEGREES_PER_RADIAN, EARTH_RADIUS_METERS, FULL_CIRCLE_DEG, RADIANS_PER_DEGREE,
    },
    memory::arena::{AzimuthGroup, SamplingArena},
};

pub(crate) struct LineConfig {
    pub(crate) start_dist: f64,
    pub(crate) max_dist: f64,
    pub(crate) interval: f64,
}

pub(crate) fn get_quality_configs(quality: u8) -> &'static [LineConfig] {
    match quality {
        2 => &[
            LineConfig {
                start_dist: 100.0,
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
                start_dist: 100.0,
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
                start_dist: 100.0,
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

// --------------------------------------------------------------------
// 数学公式: 球面三角法による順問題
// 出発点の座標、方位角、大円距離から、目標点の緯度・経度を計算する。
// ※ パフォーマンス最適化のため、sin/cosの事前計算値を引数に取る
// --------------------------------------------------------------------
pub(crate) fn calc_destination_coordinate(
    sl_sin: f64,
    sl_cos: f64,
    start_lng_rad: f64,
    az_sin: f64,
    az_cos: f64,
    dist_meters: f64,
) -> (f64, f64) {
    let angular_distance = dist_meters / EARTH_RADIUS_METERS;
    let ad_sin = angular_distance.sin();
    let ad_cos = angular_distance.cos();

    let target_lat_rad = (sl_sin * ad_cos + sl_cos * ad_sin * az_cos).asin();
    let target_lng_rad =
        start_lng_rad + (az_sin * ad_sin * sl_cos).atan2(ad_cos - sl_sin * target_lat_rad.sin());

    (target_lat_rad, target_lng_rad)
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

    let num_azimuths = (FULL_CIRCLE_DEG / step_deg).floor() as usize;

    let start_lat_rad = start_lat * RADIANS_PER_DEGREE;
    let start_lng_rad = start_lng * RADIANS_PER_DEGREE;

    let sl_sin = start_lat_rad.sin();
    let sl_cos = start_lat_rad.cos();

    for i in 0..num_azimuths {
        let azimuth_deg = (i as f64) * step_deg;
        let azimuth_rad = azimuth_deg * RADIANS_PER_DEGREE;

        let az_sin = azimuth_rad.sin();
        let az_cos = azimuth_rad.cos();

        let start_idx = arena.lats.len();

        for config in configs {
            let mut dist = config.start_dist;
            while dist <= config.max_dist {
                let (lat_rad, lng_rad) = calc_destination_coordinate(
                    sl_sin,
                    sl_cos,
                    start_lng_rad,
                    az_sin,
                    az_cos,
                    dist,
                );

                arena.lats.push(lat_rad * DEGREES_PER_RADIAN);
                arena.lngs.push(lng_rad * DEGREES_PER_RADIAN);
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
