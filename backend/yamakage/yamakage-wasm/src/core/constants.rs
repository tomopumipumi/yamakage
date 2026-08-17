use std::f64;

/// Conversion factor from radians to degrees.
/// ラジアンから度への変換係数。
pub(crate) const DEGREES_PER_RADIAN: f64 = 180.0 / f64::consts::PI;

/// Conversion factor from degrees to radians.
/// 度からラジアンへの変換係数。
pub(crate) const RADIANS_PER_DEGREE: f64 = f64::consts::PI / 180.0;

/// The number of degrees in a full circle.
/// 完全な円の角度（360度）。
pub(crate) const FULL_CIRCLE_DEG: f64 = 360.0;

/// Average radius of the Earth in meters.
/// 地球の平均半径 (メートル)。
pub(crate) const EARTH_RADIUS_METERS: f64 = 6371000.0;

/// Coefficient for the combined effect of Earth's curvature and atmospheric refraction.
/// Represents (1 - k) where k is the refraction coefficient (~0.14).
/// 両差係数（地球の曲率と大気差を合成した係数）。kを大気の屈折係数(~0.14)としたときの (1 - k) の値。
pub(crate) const CURVATURE_AND_REFRACTION_COEFFICIENT: f64 = 0.86;

/// Apparent radius of the Sun in the sky: approx. 16 arcminutes = 0.266 degrees.
/// 太陽の視半径（天球上での見かけの半径）：約16分 = 0.266度。
pub(crate) const SUN_APPARENT_RADIUS_DEG: f64 = 0.266;

/// Standard horizon elevation for defining sunrise and sunset.
/// Considers atmospheric refraction (34 arcminutes) and the Sun's apparent radius (16 arcminutes),
/// placing the horizon at 50 arcminutes (approx. -0.833 degrees) below the horizontal.
/// 標準的な地平線・水平線の仰角（日の出・日の入の定義）。
/// 大気差（34分）と太陽の視半径（16分）を足した50分（約0.833度）を地平線下とする。
pub(crate) const SUN_STANDARD_HORIZON_ELEVATION_DEG: f64 = -0.833;

/// Number of milliseconds in a minute.
/// 1分間のミリ秒数。
pub(crate) const MS_PER_MINUTE: f64 = 60000.0;

/// Number of milliseconds in a second.
/// 1秒間のミリ秒数。
pub(crate) const MS_PER_SECOND: f64 = 1000.0;
