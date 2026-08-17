use chrono::{TimeZone, Utc};
use solar_positioning::{RefractionCorrection, spa, time::DeltaT};

/// Represents the calculated position of the sun in the sky.
/// 計算された天球上での太陽の位置を表す構造体。
pub struct SunPosition {
    /// Azimuth angle of the sun in degrees (measured clockwise from North).
    /// 太陽の方位角（度）。北を基準として時計回りに測定されます。
    pub azimuth_deg: f64,

    /// Altitude (elevation) angle of the sun in degrees above the horizon.
    /// 太陽の高度・仰角（度）。地平線を0度として測定されます。
    pub altitude_deg: f64,
}

/// Calculates the sun's azimuth and altitude for a given time and geographic location.
/// 指定された時刻と位置における太陽の方位角と高度を計算します。
///
/// This function utilizes the Solar Position Algorithm (SPA) and includes standard atmospheric refraction correction.
/// この関数はSolar Position Algorithm (SPA) を使用し、標準的な大気差補正を含みます。
///
/// # Arguments
/// * `timestamp_ms` - Unix timestamp in milliseconds / Unixタイムスタンプ（ミリ秒）
/// * `lat` - Latitude in degrees / 緯度（度）
/// * `lng` - Longitude in degrees / 経度（度）
///
/// # Returns
/// A `SunPosition` struct containing the calculated angles. Returns 0.0 for both if the calculation fails.
/// 計算された角度を含む `SunPosition` 構造体を返します。計算に失敗した場合は両方の角度に 0.0 を返します。
pub fn get_sun_position(timestamp_ms: f64, lat: f64, lng: f64) -> SunPosition {
    let dt = Utc
        .timestamp_millis_opt(timestamp_ms as i64)
        .single()
        .unwrap_or_else(|| {
            Utc.timestamp_opt(0, 0)
                .single()
                .expect("UNIX EPOCH always valid")
        });

    let delta_t = DeltaT::estimate_from_date_like(dt).unwrap_or(69.0);

    match spa::solar_position(
        dt,
        lat,
        lng,
        0.0,
        delta_t,
        Some(RefractionCorrection::standard()),
    ) {
        Ok(pos) => SunPosition {
            azimuth_deg: pos.azimuth(),
            altitude_deg: pos.elevation_angle(),
        },
        Err(_) => SunPosition {
            azimuth_deg: 0.0,
            altitude_deg: 0.0,
        },
    }
}
