use crate::schemas::error::EngineError;

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
}
