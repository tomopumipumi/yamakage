use std::fmt;

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
            Self::InvalidLatitude(v) => {
                write!(f, "Latitude must be between -90 and 90, got {}", v)
            }
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

#[cfg(test)]
mod tests {

    use crate::schemas::calculation_context::CalculationContext;

    use super::*;

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
