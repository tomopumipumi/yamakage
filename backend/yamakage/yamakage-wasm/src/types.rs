use std::fmt;

#[derive(Clone, Debug)]
pub struct ShadowResultWasm {
    pub is_polar: bool,
    pub sunset_time_unix: f64,
    pub minutes_to_sunset: f64,
    pub sunrise_time_unix: f64,
    pub minutes_to_sunrise: f64,
    pub azimuth_profiles: Vec<TerrainAzimuthProfileWasm>,
    pub sun_path: Vec<SunPathPointWasm>,
}

impl ShadowResultWasm {
    pub fn pack_into_buffer(&self, buffer: &mut Vec<f64>) {
        buffer.push(if self.is_polar { 1.0 } else { 0.0 });
        buffer.push(self.sunset_time_unix);
        buffer.push(self.minutes_to_sunset);
        buffer.push(self.sunrise_time_unix);
        buffer.push(self.minutes_to_sunrise);
        buffer.push(self.azimuth_profiles.len() as f64);
        buffer.push(self.sun_path.len() as f64);
        buffer.push(0.0);

        for p in &self.azimuth_profiles {
            buffer.push(p.azimuth_deg);
            buffer.push(p.max_obstacle_angle_deg);
            if let Some(pt) = &p.highest_point {
                buffer.push(pt.lat);
                buffer.push(pt.lng);
                buffer.push(p.highest_altitude);
            } else {
                buffer.push(f64::NAN);
                buffer.push(f64::NAN);
                buffer.push(0.0);
            }
        }

        for sp in &self.sun_path {
            buffer.push(sp.time);
            buffer.push(sp.azimuth);
            buffer.push(sp.altitude);
        }
    }
}

#[derive(Clone, Debug)]
pub struct TerrainAzimuthProfileWasm {
    pub azimuth_deg: f64,
    pub max_obstacle_angle_deg: f64,
    pub highest_point: Option<CoordinateWasm>,
    pub highest_altitude: f64,
}

#[derive(Clone, Debug)]
pub struct CoordinateWasm {
    pub lat: f64,
    pub lng: f64,
}

#[derive(Clone, Debug)]
pub struct SunPathPointWasm {
    pub time: f64,
    pub azimuth: f64,
    pub altitude: f64,
}

#[derive(Debug)]
pub enum EngineError {
    InvalidLatitude(f64),
    InvalidLongitude(f64),
    InvalidAltitude(f64),
    InvalidTime,
}

impl fmt::Display for EngineError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidLatitude(v) => write!(f, "Latitude must be between -90 and 90, got {}", v),
            Self::InvalidLongitude(v) => {
                write!(f, "Longitude must be between -180 and 180, got {}", v)
            }
            Self::InvalidAltitude(v) => {
                write!(f, "Altitude must be a finite number, got {}", v)
            }
            Self::InvalidTime => write!(f, "Invalid target time"),
        }
    }
}

impl std::error::Error for EngineError {}

#[derive(Debug)]
pub struct CalculationContext {
    pub lat: f64,
    pub lng: f64,
    pub target_time_ms: f64,
    pub eye_level_altitude: f64,
}

impl CalculationContext {
    pub fn try_new(
        lat: f64,
        lng: f64,
        target_time_ms: f64,
        current_altitude: f64,
    ) -> Result<Self, EngineError> {
        if !(-90.0..=90.0).contains(&lat) {
            return Err(EngineError::InvalidLatitude(lat));
        }
        if !(-180.0..=180.0).contains(&lng) {
            return Err(EngineError::InvalidLongitude(lng));
        }

        if !target_time_ms.is_finite() {
            return Err(EngineError::InvalidTime);
        }

        if !current_altitude.is_finite() {
            return Err(EngineError::InvalidAltitude(current_altitude));
        }

        // "target_time_ms < 0.0" is permitted.
        if target_time_ms.is_nan() {
            return Err(EngineError::InvalidTime);
        }

        Ok(Self {
            lat,
            lng,
            target_time_ms,
            eye_level_altitude: current_altitude + 1.5,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_context() {
        let ctx = CalculationContext::try_new(35.0, 135.0, 1700000000000.0, 10.0).unwrap();
        assert_eq!(ctx.lat, 35.0);
        assert_eq!(ctx.eye_level_altitude, 11.5);
    }

    #[test]
    fn test_invalid_latitude() {
        let err = CalculationContext::try_new(91.0, 135.0, 1700000000000.0, 10.0).unwrap_err();
        assert!(matches!(err, EngineError::InvalidLatitude(_)));
    }

    #[test]
    fn test_invalid_longitude() {
        let err = CalculationContext::try_new(35.0, 181.0, 1700000000000.0, 10.0).unwrap_err();
        assert!(matches!(err, EngineError::InvalidLongitude(_)));
    }

    #[test]
    fn test_invalid_time() {
        let err_nan = CalculationContext::try_new(35.0, 135.0, f64::NAN, 10.0).unwrap_err();
        assert!(matches!(err_nan, EngineError::InvalidTime));

        let err_inf = CalculationContext::try_new(35.0, 135.0, f64::INFINITY, 10.0).unwrap_err();
        assert!(matches!(err_inf, EngineError::InvalidTime));
    }

    #[test]
    fn test_pack_into_buffer() {
        let mut buffer = Vec::new();
        let result = ShadowResultWasm {
            is_polar: false,
            sunset_time_unix: 1000.0,
            minutes_to_sunset: 10.0,
            sunrise_time_unix: 2000.0,
            minutes_to_sunrise: 20.0,
            azimuth_profiles: vec![TerrainAzimuthProfileWasm {
                azimuth_deg: 90.0,
                max_obstacle_angle_deg: 5.0,
                highest_point: Some(CoordinateWasm {
                    lat: 35.1,
                    lng: 135.1,
                }),
                highest_altitude: 100.0,
            }],
            sun_path: vec![SunPathPointWasm {
                time: 1500.0,
                azimuth: 180.0,
                altitude: 45.0,
            }],
        };

        result.pack_into_buffer(&mut buffer);

        assert_eq!(buffer.len(), 16);

        // Header
        assert_eq!(buffer[0], 0.0); // is_polar
        assert_eq!(buffer[1], 1000.0); // sunset
        assert_eq!(buffer[5], 1.0); // num_profiles
        assert_eq!(buffer[6], 1.0); // num_sun_path

        // Profile
        assert_eq!(buffer[8], 90.0); // azimuth_deg
        assert_eq!(buffer[9], 5.0); // max_obstacle_angle_deg
        assert_eq!(buffer[10], 35.1); // lat
        assert_eq!(buffer[11], 135.1); // lng
        assert_eq!(buffer[12], 100.0); // highest_altitude

        // Sun path
        assert_eq!(buffer[13], 1500.0); // time
        assert_eq!(buffer[14], 180.0); // azimuth
        assert_eq!(buffer[15], 45.0); // altitude
    }
}
