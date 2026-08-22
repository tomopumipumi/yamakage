#[cfg(test)]
pub(crate) mod tests {
    use crate::{
        core::{
            azimuth_profile::TerrainAzimuthProfileWasm,
            simulate_moon_path::simulate_moon_path,
        },
        schemas::calculation_context::CalculationContext,
    };

    // --------------------------------------------------------------------
    // Helper: Create a dummy profile
    // ヘルパー: ダミーの地形プロファイルを作成する関数
    // --------------------------------------------------------------------
    fn make_profile(azimuth: f64, angle: f64) -> TerrainAzimuthProfileWasm {
        TerrainAzimuthProfileWasm {
            azimuth_deg: azimuth,
            max_obstacle_angle_deg: angle,
            highest_point: None,
            highest_altitude: 100.0,
            distance: 1000.0,
        }
    }

    // --------------------------------------------------------------------
    // Integration test: Simulate moon path
    // 統合テスト: 月の軌道シミュレーションの検証
    // --------------------------------------------------------------------
    #[test]
    fn test_simulate_moon_path_basic() {
        // Create context for Tokyo (Lat: 35.68, Lng: 139.76, Altitude: 10m)
        // 東京の座標 (緯度: 35.68, 経度: 139.76, 標高: 10m) のコンテキストを作成
        let ctx = CalculationContext::try_new(35.68, 139.76, 1704078000000.0, 10.0).unwrap();
        
        // Dummy obstacle profiles covering 4 directions (90 degree steps)
        // 4方向(90度ステップ)をカバーするダミーの障害物プロファイル
        let profiles = vec![
            make_profile(0.0, 5.0),
            make_profile(90.0, 10.0),
            make_profile(180.0, 5.0),
            make_profile(270.0, 15.0),
        ];

        // Execute the moon simulation
        // 月のシミュレーションを実行
        let result = simulate_moon_path(&ctx, &profiles);

        // 1. Check fraction and phase bounds
        // 1. 照度と月齢が有効な範囲(0.0 ~ 1.0)に収まっているか確認
        assert!(
            result.fraction >= 0.0 && result.fraction <= 1.0,
            "Fraction out of bounds: {}",
            result.fraction
        );
        assert!(
            result.phase >= 0.0 && result.phase <= 1.0,
            "Phase out of bounds: {}",
            result.phase
        );

        // 2. Mid-latitudes should rarely experience polar day/night for the moon
        // 2. 中緯度地域では月の白夜・極夜現象は発生しないため、is_polar は false になること
        assert!(
            !result.is_polar,
            "Mid-latitude location should not be polar"
        );

        // 3. Moon path array should be populated with recorded intervals
        // 3. 月の軌道データ配列が、指定されたインターバルで記録・生成されていること
        assert!(
            !result.moon_path.is_empty(),
            "Moon path should not be empty"
        );

        // 4. Validate that generated moon path respects altitude constraints (> -15 degrees)
        // 4. 生成された軌道データが高度の制約(-15度以上)を満たしていることの確認
        for point in result.moon_path.iter() {
            assert!(
                point.altitude > -16.0,
                "Recorded moon path point has altitude too low: {}",
                point.altitude
            );
        }

        // 5. Ensure sunset and sunrise (moonset/moonrise) times are correctly computed or defaulted
        // 5. 月の出・月の入りの時間が正しく計算されている、またはデフォルト値に収まっていること
        // Valid unix timestamps should be > 0.0, or -1.0 if not occurred within window.
        assert!(
            result.moonset_time_unix > 0.0 || result.moonset_time_unix == -1.0,
            "Invalid moonset time: {}", result.moonset_time_unix
        );
        assert!(
            result.moonrise_time_unix > 0.0 || result.moonrise_time_unix == -1.0,
            "Invalid moonrise time: {}", result.moonrise_time_unix
        );
    }
}