#[cfg(test)]
pub(crate) mod tests {
    use crate::core::moon_calc::{get_moon_illumination, get_moon_position};

    // --------------------------------------------------------------------
    // Bounds and Validity check / 境界値と有効性の確認
    // --------------------------------------------------------------------
    #[test]
    fn test_get_moon_position_bounds() {
        // Valid timestamp (Tokyo, roughly typical coordinates)
        // 有効なタイムスタンプ (東京の一般的な座標)
        let pos = get_moon_position(1718000000000.0, 35.68, 139.76);

        // Azimuth: 0 to 360 degrees
        // 方位角: 0〜360度の範囲に収まること
        assert!(
            pos.azimuth_deg >= 0.0 && pos.azimuth_deg < 360.0,
            "Azimuth out of bounds: {}",
            pos.azimuth_deg
        );

        // Altitude: -90 to +90 degrees
        // 高度: -90〜+90度の範囲に収まること
        assert!(
            pos.altitude_deg >= -90.0 && pos.altitude_deg <= 90.0,
            "Altitude out of bounds: {}",
            pos.altitude_deg
        );

        // Distance: Earth-Moon distance is roughly between 356,400 km and 406,700 km
        // 地球から月までの距離: およそ 356,400 km 〜 406,700 km の範囲内であること
        assert!(
            pos.distance_km > 350000.0 && pos.distance_km < 410000.0,
            "Distance out of realistic bounds: {} km",
            pos.distance_km
        );
    }

    // --------------------------------------------------------------------
    // Moon Phase and Illumination check / 月齢(位相)と照度(輝面比)の確認
    // --------------------------------------------------------------------
    #[test]
    fn test_moon_phase_and_fraction() {
        // Test Case 1: Known Full Moon (Jan 25, 2024, 17:54 UTC)
        // テストケース1: 既知の満月 (2024年1月25日 17:54 UTC) -> 1706205240000 ms
        let full_moon_ms = 1706205240000.0;
        let illum_full = get_moon_illumination(full_moon_ms);
        
        // Fraction should be extremely close to 1.0 (100% illuminated)
        // 輝面比(照度)は 1.0 (100%) に極めて近い値であること
        assert!(
            illum_full.fraction > 0.99,
            "Expected full moon fraction near 1.0, got {}",
            illum_full.fraction
        );
        
        // Phase should be near 0.5 for Full Moon
        // 満月の場合、位相(月齢)は 0.5 に極めて近い値であること
        assert!(
            (illum_full.phase - 0.5).abs() < 0.02,
            "Expected full moon phase near 0.5, got {}",
            illum_full.phase
        );

        // Test Case 2: Known New Moon (Jan 11, 2024, 11:57 UTC)
        // テストケース2: 既知の新月 (2024年1月11日 11:57 UTC) -> 1704974220000 ms
        let new_moon_ms = 1704974220000.0;
        let illum_new = get_moon_illumination(new_moon_ms);
        
        // Fraction should be extremely close to 0.0 (0% illuminated)
        // 輝面比(照度)は 0.0 (0%) に極めて近い値であること
        assert!(
            illum_new.fraction < 0.01,
            "Expected new moon fraction near 0.0, got {}",
            illum_new.fraction
        );
        
        // Phase should be near 0.0 or 1.0 for New Moon
        // 新月の場合、位相(月齢)は 0.0 または 1.0 に極めて近い値であること
        let phase_dist = illum_new.phase.min(1.0 - illum_new.phase);
        assert!(
            phase_dist < 0.02,
            "Expected new moon phase near 0.0 or 1.0, got {}",
            illum_new.phase
        );
    }
}