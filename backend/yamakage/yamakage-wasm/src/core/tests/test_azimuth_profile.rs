#[cfg(test)]
pub(crate) mod tests {
    use crate::{
        core::{
            azimuth_profile::{calc_apparent_elevation_angle_deg, calculate_azimuth_profiles},
            constants::SUN_STANDARD_HORIZON_ELEVATION_DEG,
        },
        memory::arena::{AzimuthGroup, SamplingArena},
    };

    // --------------------------------------------------------------------
    // 1. Pure function tests (Apparent Elevation Angle Calculation)
    // 1. 純粋関数のテスト (見かけの仰角計算)
    // --------------------------------------------------------------------
    #[test]
    fn test_calc_apparent_elevation_angle_deg() {
        // Condition 1: Target and eye level are at the same altitude
        // ターゲットと視点の標高が同じ場合
        // Due to the Earth's curvature, the apparent angle should be slightly negative
        // 地球の丸み(球差)の影響で、見かけの仰角はわずかにマイナスになること
        let angle_same_alt = calc_apparent_elevation_angle_deg(10000.0, 10.0, 10.0);
        assert!(angle_same_alt < 0.0);

        // Condition 2: Target is significantly higher than eye level
        // ターゲットが視点より十分に高い場合 (例: 距離1kmで標高差1km)
        let angle_high_target = calc_apparent_elevation_angle_deg(1000.0, 1000.0, 0.0);
        assert!(angle_high_target > 40.0 && angle_high_target < 50.0);

        // Condition 3: Target is lower than eye level
        // ターゲットが視点より低い場合
        let angle_low_target = calc_apparent_elevation_angle_deg(1000.0, 0.0, 1000.0);
        assert!(angle_low_target < 0.0);
    }

    // --------------------------------------------------------------------
    // 2. Integration tests (Azimuth Profiles Generation)
    // 2. 統合テスト (方位ごとのプロファイル生成)
    // --------------------------------------------------------------------
    #[test]
    fn test_calculate_azimuth_profiles_empty() {
        let arena = SamplingArena::new();
        let profiles = calculate_azimuth_profiles(&arena, 0.0);

        // Should return an empty vector / 空のベクタが返ること
        assert!(profiles.is_empty());
    }

    #[test]
    fn test_calculate_azimuth_profiles_below_horizon() {
        let mut arena = SamplingArena::new();

        // Setup: 10km away, 0m altitude (definitely below horizon)
        // セットアップ: 距離100m, 標高0m (確実に地平線下になる設定)
        arena.lats.push(35.0);
        arena.lngs.push(135.0);
        arena.distances.push(100.0);
        arena.elevations.push(0.0);

        arena.groups.push(AzimuthGroup {
            azimuth_deg: 90.0,
            range: 0..1,
        });

        // Calculate with eye level at 100m / 視点の標高100mで計算
        let profiles = calculate_azimuth_profiles(&arena, 100.0);
        assert_eq!(profiles.len(), 1);

        let p = &profiles[0];

        // Angle should be clipped to the standard horizon elevation
        // 仰角が標準の地平線仰角にクリップされること
        assert_eq!(p.max_obstacle_angle_deg, SUN_STANDARD_HORIZON_ELEVATION_DEG);

        // No obstacle data should be recorded
        // 障害物データは記録されないこと
        assert!(p.highest_point.is_none());
        assert_eq!(p.highest_altitude, 0.0);
    }

    #[test]
    fn test_calculate_azimuth_profiles_above_horizon() {
        let mut arena = SamplingArena::new();

        // Setup: 1km away, 1000m altitude (clearly an obstacle)
        // セットアップ: 距離1km, 標高1000m (明らかな障害物)
        arena.lats.push(35.1);
        arena.lngs.push(135.1);
        arena.distances.push(1000.0);
        arena.elevations.push(1000.0);

        arena.groups.push(AzimuthGroup {
            azimuth_deg: 180.0,
            range: 0..1,
        });

        let profiles = calculate_azimuth_profiles(&arena, 0.0);
        let p = &profiles[0];

        // Angle should be greater than horizon
        // 仰角は地平線より上になること
        assert!(p.max_obstacle_angle_deg > SUN_STANDARD_HORIZON_ELEVATION_DEG);

        // Obstacle data should be recorded properly
        // 障害物データが正しく記録されること
        assert!(p.highest_point.is_some());
        let coord = p.highest_point.as_ref().unwrap();
        assert_eq!(coord.lat, 35.1);
        assert_eq!(coord.lng, 135.1);
        assert_eq!(p.highest_altitude, 1000.0);
    }

    #[test]
    fn test_calculate_azimuth_profiles_max_selection() {
        let mut arena = SamplingArena::new();

        // Point 1: 1km away, 100m altitude
        // ポイント1: 距離1km, 標高100m
        arena.lats.push(35.1);
        arena.lngs.push(135.1);
        arena.distances.push(1000.0);
        arena.elevations.push(100.0);

        // Point 2: 2km away, 500m altitude (Provides higher elevation angle)
        // ポイント2: 距離2km, 標高500m (ポイント1より仰角が高くなる)
        arena.lats.push(35.2);
        arena.lngs.push(135.2);
        arena.distances.push(2000.0);
        arena.elevations.push(500.0);

        // Point 3: 3km away, 10m altitude (Lowest elevation angle)
        // ポイント3: 距離3km, 標高10m (仰角が最も低くなる)
        arena.lats.push(35.3);
        arena.lngs.push(135.3);
        arena.distances.push(3000.0);
        arena.elevations.push(10.0);

        // Group containing all 3 points / 3つのポイントをすべて含むグループ
        arena.groups.push(AzimuthGroup {
            azimuth_deg: 270.0,
            range: 0..3,
        });

        let profiles = calculate_azimuth_profiles(&arena, 0.0);
        let p = &profiles[0];

        // Point 2 should be selected as it has the highest apparent angle
        // 見かけの仰角が最も高くなるポイント2が選出されること
        let coord = p.highest_point.as_ref().unwrap();
        assert_eq!(coord.lat, 35.2);
        assert_eq!(coord.lng, 135.2);
        assert_eq!(p.highest_altitude, 500.0);
    }
}
