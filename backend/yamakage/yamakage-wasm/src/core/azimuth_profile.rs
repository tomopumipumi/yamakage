use crate::{
    core::constants::{
        CURVATURE_AND_REFRACTION_COEFFICIENT, DEGREES_PER_RADIAN, EARTH_RADIUS_METERS,
        SUN_STANDARD_HORIZON_ELEVATION_DEG,
    },
    memory::arena::SamplingArena,
};

/// Represents a geographic coordinate.
/// 地理的座標を表す構造体。
#[derive(Clone, Debug)]
pub struct CoordinateWasm {
    /// Latitude in degrees.
    /// 緯度（度）。
    pub lat: f64,

    /// Longitude in degrees.
    /// 経度（度）。
    pub lng: f64,
}

/// Represents the terrain obstacle profile for a specific azimuth direction.
/// 特定の方位角に対する地形の障害物プロファイルを表す構造体。
#[derive(Clone, Debug)]
pub struct TerrainAzimuthProfileWasm {
    /// Azimuth angle in degrees.
    /// 方位角（度）。
    pub azimuth_deg: f64,

    /// The maximum apparent elevation angle of the obstacle in this direction.
    /// この方向における障害物の最大見かけ仰角（度）。
    pub max_obstacle_angle_deg: f64,

    /// The geographic coordinate of the obstacle that forms the highest angle.
    /// 最大仰角を形成する障害物の地理的座標。
    pub highest_point: Option<CoordinateWasm>,

    /// The actual altitude of the highest obstacle point in meters.
    /// 最大仰角を形成する障害物の実際の標高（メートル）。
    pub highest_altitude: f64,

    /// The distance from the origin to the highest obstacle point in meters.
    /// 起点から最大仰角を形成する障害物までの距離（メートル）。
    pub distance: f64,
}

/// Calculates the apparent elevation angle of a target point, accounting for Earth's curvature and atmospheric refraction.
/// 地球の曲率(球差)と大気の屈折(気差)による「両差」を考慮し、目の高さからの真の見かけの仰角を算出します。
///
/// Distant objects geometrically sink due to Earth's curvature, but appear slightly raised due to atmospheric refraction.
/// 遠方の物体は地球の丸みで沈む(球差)が、大気の屈折により浮き上がって見える(気差)現象を補正します。
///
/// # Arguments
/// * `distance_meters` - Distance to the target in meters / 目標点までの距離（メートル）
/// * `target_altitude` - Actual altitude of the target in meters / 目標点の実際の標高（メートル）
/// * `eye_level_altitude` - Altitude of the observer's eye level in meters / 観測者の目の高さの標高（メートル）
///
/// # Returns
/// Apparent elevation angle in degrees.
/// 見かけの仰角（度）を返します。
pub(crate) fn calc_apparent_elevation_angle_deg(
    distance_meters: f64,
    target_altitude: f64,
    eye_level_altitude: f64,
) -> f64 {
    let curvature_and_refraction_drop = (distance_meters * distance_meters)
        / (2.0 * EARTH_RADIUS_METERS)
        * CURVATURE_AND_REFRACTION_COEFFICIENT;
    let effective_altitude_diff =
        target_altitude - eye_level_altitude - curvature_and_refraction_drop;
    effective_altitude_diff.atan2(distance_meters) * DEGREES_PER_RADIAN
}

/// Calculates the maximum obstacle elevation angle for each azimuth direction in the sampling arena.
/// サンプリングアリーナ内の各方位角に対して、最大の障害物仰角を計算し、プロファイルを生成します。
///
/// # Arguments
/// * `arena` - The sampling arena containing distances, elevations, and coordinates / 距離、標高、座標を含むサンプリングアリーナ
/// * `eye_level_altitude` - Altitude of the observer's eye level in meters / 観測者の目の高さの標高（メートル）
///
/// # Returns
/// A vector of terrain azimuth profiles.
/// 地形方位角プロファイルのベクタ（配列）を返します。
pub fn calculate_azimuth_profiles(
    arena: &SamplingArena,
    eye_level_altitude: f64,
) -> Vec<TerrainAzimuthProfileWasm> {
    arena
        .groups
        .iter()
        .map(|group| {
            let range = group.range.clone();

            // Find the point that creates the highest apparent elevation angle
            // 見かけの仰角が最も高くなるポイント（最大の障害物）を抽出
            let max_point = range
                .map(|i| {
                    let alt = arena.elevations[i];
                    let dist = arena.distances[i];
                    let angle_deg =
                        calc_apparent_elevation_angle_deg(dist, alt, eye_level_altitude);
                    (angle_deg, arena.lats[i], arena.lngs[i], alt, dist)
                })
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap_or(std::cmp::Ordering::Equal));

            let (max_angle, max_lat, max_lng, max_alt, max_dist) =
                max_point.unwrap_or((SUN_STANDARD_HORIZON_ELEVATION_DEG, 0.0, 0.0, 0.0, 0.0));

            // Ensure the angle does not fall below the standard mathematical horizon
            // 仰角が標準的な地平線・水平線を下回らないように調整
            let angle = max_angle.max(SUN_STANDARD_HORIZON_ELEVATION_DEG);

            TerrainAzimuthProfileWasm {
                azimuth_deg: group.azimuth_deg,
                max_obstacle_angle_deg: angle,
                highest_point: if angle > SUN_STANDARD_HORIZON_ELEVATION_DEG {
                    Some(CoordinateWasm {
                        lat: max_lat,
                        lng: max_lng,
                    })
                } else {
                    None
                },
                highest_altitude: if angle > SUN_STANDARD_HORIZON_ELEVATION_DEG {
                    max_alt
                } else {
                    0.0
                },
                distance: if angle > SUN_STANDARD_HORIZON_ELEVATION_DEG {
                    max_dist
                } else {
                    0.0
                },
            }
        })
        .collect()
}
