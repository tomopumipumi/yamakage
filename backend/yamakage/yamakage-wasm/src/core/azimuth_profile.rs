use crate::{
    core::constants::{
        CURVATURE_AND_REFRACTION_COEFFICIENT, DEGREES_PER_RADIAN, EARTH_RADIUS_METERS,
        SUN_STANDARD_HORIZON_ELEVATION_DEG,
    },
    memory::arena::SamplingArena,
};

#[derive(Clone, Debug)]
pub struct CoordinateWasm {
    pub lat: f64,
    pub lng: f64,
}

#[derive(Clone, Debug)]
pub struct TerrainAzimuthProfileWasm {
    pub azimuth_deg: f64,
    pub max_obstacle_angle_deg: f64,
    pub highest_point: Option<CoordinateWasm>,
    pub highest_altitude: f64,
}

// --------------------------------------------------------------------
// 数学公式: 見かけの仰角の算出 (Apparent Elevation Angle)
// 遠方の物体は地球の丸みで沈む(球差)が、大気の屈折により浮き上がって見える(気差)。
// これら「両差」を補正した上で、目の高さからの真の仰角を求める。
// --------------------------------------------------------------------
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
                    let angle_deg =
                        calc_apparent_elevation_angle_deg(dist, alt, eye_level_altitude);
                    (angle_deg, arena.lats[i], arena.lngs[i], alt)
                })
                .max_by(|a, b| a.0.partial_cmp(&b.0).unwrap_or(std::cmp::Ordering::Equal));

            let (max_angle, max_lat, max_lng, max_alt) =
                max_point.unwrap_or((SUN_STANDARD_HORIZON_ELEVATION_DEG, 0.0, 0.0, 0.0));

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
            }
        })
        .collect()
}
