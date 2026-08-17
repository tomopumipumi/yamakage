use crate::{
    core::constants::{
        DEGREES_PER_RADIAN, EARTH_RADIUS_METERS, FULL_CIRCLE_DEG, RADIANS_PER_DEGREE,
    },
    memory::arena::{AzimuthGroup, SamplingArena},
};

/// Configuration for a sampling line segment along an azimuth.
/// 方位角に沿ったサンプリングラインのセグメント設定を定義する構造体。
pub(crate) struct LineConfig {
    /// The starting distance from the origin in meters.
    /// 起点からの開始距離（メートル）。
    pub(crate) start_dist: f64,

    /// The maximum distance from the origin in meters.
    /// 起点からの最大距離（メートル）。
    pub(crate) max_dist: f64,

    /// The interval between sampling points in meters.
    /// サンプリングポイント間の間隔（メートル）。
    pub(crate) interval: f64,
}

/// Retrieves the sampling line configurations based on the specified quality level.
/// 指定された品質レベルに基づくサンプリングラインの設定を取得します。
///
/// Higher quality levels result in denser and farther-reaching sampling points.
/// 品質レベルが高いほど、より遠くまで高密度なサンプリングポイントが設定されます。
///
/// # Arguments
/// * `quality` - The quality level (e.g., 1 for standard, 2 for high) / 品質レベル（1:標準, 2:高品質 など）
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

/// Direct problem of spherical trigonometry.
/// Calculates the target latitude and longitude given a starting coordinate, azimuth, and great-circle distance.
///
/// 球面三角法による順問題。
/// 出発点の座標、方位角、大円距離から、目標点の緯度・経度を計算します。
///
/// For performance optimization, pre-calculated sine and cosine values are passed as arguments.
/// パフォーマンス最適化のため、事前に計算されたsin/cos値を引数に取ります。
///
/// # Arguments
/// * `sl_sin` - Sine of the starting latitude / 出発点緯度のsin値
/// * `sl_cos` - Cosine of the starting latitude / 出発点緯度のcos値
/// * `start_lng_rad` - Starting longitude in radians / 出発点経度(ラジアン)
/// * `az_sin` - Sine of the azimuth angle / 方位角のsin値
/// * `az_cos` - Cosine of the azimuth angle / 方位角のcos値
/// * `dist_meters` - Distance to the target in meters / 目標点までの距離(メートル)
///
/// # Returns
/// A tuple containing the target latitude and longitude in radians.
/// 目標点の緯度と経度（ラジアン）のタプルを返します。
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

    let mut normalized_lng_rad = target_lng_rad % (2.0 * std::f64::consts::PI);
    if normalized_lng_rad > std::f64::consts::PI {
        normalized_lng_rad -= 2.0 * std::f64::consts::PI;
    } else if normalized_lng_rad <= -std::f64::consts::PI {
        normalized_lng_rad += 2.0 * std::f64::consts::PI;
    }

    (target_lat_rad, normalized_lng_rad)
}

/// Generates geographic sampling points around a starting coordinate based on azimuth steps and quality.
/// 指定された方位角のステップと品質に基づき、開始座標の周囲360度にサンプリングポイントを生成します。
///
/// The generated points are stored in the provided `SamplingArena` for further elevation processing.
/// 生成されたポイント群は、標高処理のために提供された `SamplingArena` に格納されます。
///
/// # Arguments
/// * `arena` - The arena where generated points and metadata will be stored / 生成されたポイントやメタデータを格納するアリーナ
/// * `start_lat` - Starting latitude in degrees / 出発点の緯度（度）
/// * `start_lng` - Starting longitude in degrees / 出発点の経度（度）
/// * `step_deg` - Angle interval between each azimuth ray in degrees / 各方位角の射線の間隔（度）
/// * `quality` - Quality level defining the distance and density of points / サンプリングの距離と密度を決定する品質レベル
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
