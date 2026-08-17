#[cfg(test)]
pub(crate) mod tests {
    use crate::core::sun_calc::get_sun_position;

    // --------------------------------------------------------------------
    // Bounds and Validity check
    // 境界値と有効性の確認
    // --------------------------------------------------------------------
    #[test]
    fn test_get_sun_position_bounds() {
        // Valid timestamp (Tokyo) / 有効なタイムスタンプ (東京)
        let pos = get_sun_position(1718000000000.0, 35.68, 139.76);

        // Azimuth: 0 to 360, Altitude: -90 to +90
        // 方位角: 0〜360度, 高度: -90〜+90度 の範囲に収まること
        assert!(pos.azimuth_deg >= 0.0 && pos.azimuth_deg <= 360.0);
        assert!(pos.altitude_deg >= -90.0 && pos.altitude_deg <= 90.0);
    }

    // --------------------------------------------------------------------
    // Day vs Night physical logic check
    // 昼夜の物理ロジック比較
    // --------------------------------------------------------------------
    #[test]
    fn test_day_and_night_altitude() {
        // Tokyo 2024-01-01 12:00 JST / 東京 2024年1月1日 正午
        let day_pos = get_sun_position(1704078000000.0, 35.68, 139.76);
        // Sun should be above horizon / 太陽が地平線上にあること
        assert!(day_pos.altitude_deg > 0.0);

        // Tokyo 2024-01-01 00:00 JST / 東京 2024年1月1日 深夜
        let night_pos = get_sun_position(1704034800000.0, 35.68, 139.76);
        // Sun should be below horizon / 太陽が地平線下にあること
        assert!(night_pos.altitude_deg < 0.0);
    }

    // --------------------------------------------------------------------
    // Error handling (Fallback)
    // エラーハンドリング (フォールバック)
    // --------------------------------------------------------------------
    #[test]
    fn test_invalid_timestamp_fallback() {
        // NaN or extreme values should fallback to UNIX EPOCH
        // NaNや極端な値はUNIXエポックにフォールバックすること
        let pos_nan = get_sun_position(f64::NAN, 35.0, 135.0);
        let pos_overflow = get_sun_position(1e30, 35.0, 135.0);
        let pos_epoch = get_sun_position(0.0, 35.0, 135.0);

        // Results must be identical to the UNIX EPOCH calculation
        // 正常なUNIXエポック時の計算結果と完全に一致すること
        assert_eq!(pos_nan.azimuth_deg, pos_epoch.azimuth_deg);
        assert_eq!(pos_nan.altitude_deg, pos_epoch.altitude_deg);

        assert_eq!(pos_overflow.azimuth_deg, pos_epoch.azimuth_deg);
        assert_eq!(pos_overflow.altitude_deg, pos_epoch.altitude_deg);
    }
}
