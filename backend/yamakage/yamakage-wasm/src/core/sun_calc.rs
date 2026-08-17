use chrono::{TimeZone, Utc};
use solar_positioning::{RefractionCorrection, spa, time::DeltaT};

pub struct SunPosition {
    pub azimuth_deg: f64,
    pub altitude_deg: f64,
}

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
