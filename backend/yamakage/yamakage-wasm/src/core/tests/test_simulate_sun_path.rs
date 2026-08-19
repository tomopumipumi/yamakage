#[cfg(test)]
pub(crate) mod tests {
    use crate::core::{
        azimuth_profile::TerrainAzimuthProfileWasm,
        constants::{MS_PER_SECOND, SUN_APPARENT_RADIUS_DEG, SUN_STANDARD_HORIZON_ELEVATION_DEG},
        simulate_sun_path::{
            SimulationState, get_interpolated_angle, is_sunrise, is_sunset, should_record_sun_path,
            step_simulation,
        },
    };

    // --------------------------------------------------------------------
    // Helper: Create a dummy profile
    // ヘルパー: ダミーのプロファイルを作成
    // --------------------------------------------------------------------
    fn make_profile(azimuth: f64, angle: f64) -> TerrainAzimuthProfileWasm {
        TerrainAzimuthProfileWasm {
            azimuth_deg: azimuth,
            max_obstacle_angle_deg: angle,
            highest_point: None,
            highest_altitude: 0.0,
            distance: 0.0,
        }
    }

    // --------------------------------------------------------------------
    // Interpolation logic tests
    // 補間ロジックのテスト
    // --------------------------------------------------------------------
    #[test]
    fn test_get_interpolated_angle() {
        // Empty profiles / プロファイルが空の場合
        let empty: Vec<TerrainAzimuthProfileWasm> = vec![];
        assert_eq!(
            get_interpolated_angle(&empty, 180.0),
            SUN_STANDARD_HORIZON_ELEVATION_DEG
        );

        // Single profile / プロファイルが1つの場合
        let single = vec![make_profile(90.0, 10.0)];
        assert_eq!(get_interpolated_angle(&single, 180.0), 10.0);

        // Multiple profiles (Normal interpolation)
        // 複数のプロファイル (通常の線形補間)
        let multi = vec![
            make_profile(0.0, 5.0),
            make_profile(90.0, 15.0),
            make_profile(180.0, 5.0),
        ];
        // 45 degrees should be exactly halfway between 0 (5deg) and 90 (15deg)
        // 45度は 0度(5度) と 90度(15度) のちょうど中間になること
        assert_eq!(get_interpolated_angle(&multi, 45.0), 10.0);
        // Exact match / 完全一致
        assert_eq!(get_interpolated_angle(&multi, 90.0), 15.0);

        // Wrap-around interpolation (crossing North / 0 degrees)
        // 0度(真北)をまたぐ場合の補間
        let wrap = vec![make_profile(10.0, 20.0), make_profile(350.0, 10.0)];
        // 0 degrees is halfway between 350 (10deg) and 10 (20deg) across the North
        // 0度は北をまたいだ 350度(10度) と 10度(20度) の中点になること
        assert_eq!(get_interpolated_angle(&wrap, 0.0), 15.0);
    }

    // --------------------------------------------------------------------
    // Sunrise / Sunset detection logic tests
    // 日の出・日没判定ロジックのテスト
    // --------------------------------------------------------------------
    #[test]
    fn test_is_sunset_and_sunrise() {
        // Assume obstacle is flat at 5.0 degrees
        // 障害物の仰角は常に 5.0度 とする
        let obs = 5.0;

        // Sunset: Sun top goes from >= obs to < obs
        // 日没: 太陽の上端が障害物以上から障害物未満に沈む瞬間
        let prev_alt_high = obs - SUN_APPARENT_RADIUS_DEG + 0.1; // Top is slightly above obs
        let curr_alt_low = obs - SUN_APPARENT_RADIUS_DEG - 0.1; // Top is slightly below obs

        assert!(is_sunset(prev_alt_high, obs, curr_alt_low, obs));
        assert!(!is_sunrise(prev_alt_high, obs, curr_alt_low, obs));

        // Sunrise: Sun top goes from <= obs to > obs
        // 日の出: 太陽の上端が障害物以下から障害物より上に昇る瞬間
        assert!(is_sunrise(curr_alt_low, obs, prev_alt_high, obs));
        assert!(!is_sunset(curr_alt_low, obs, prev_alt_high, obs));
    }

    // --------------------------------------------------------------------
    // Path recording condition tests
    // 軌道記録条件のテスト
    // --------------------------------------------------------------------
    #[test]
    fn test_should_record_sun_path() {
        let interval = 10;

        // Valid case: Divisible by interval, within time range, altitude > -15.0
        // 有効なケース: インターバル割り切れ、期間内、高度-15度以上
        assert!(should_record_sun_path(20, interval, -10.0));

        // Invalid: Not divisible by interval / インターバルで割り切れない
        assert!(!should_record_sun_path(25, interval, 10.0));

        // Invalid: Out of time range / 期間外 (720分超過)
        assert!(!should_record_sun_path(730, interval, 10.0));

        // Invalid: Altitude too low / 高度が低すぎる (-15度以下)
        assert!(!should_record_sun_path(20, interval, -16.0));
    }

    // --------------------------------------------------------------------
    // State update logic test
    // 状態更新(1ステップ)のテスト
    // --------------------------------------------------------------------
    #[test]
    fn test_step_simulation() {
        let initial_alt = 10.0;
        let initial_obs = 5.0;
        let mut state = SimulationState::new(initial_alt, initial_obs);

        // Step forward to trigger sunset
        // 時間を進めて日没をトリガーする
        let current_ms = 100000.0;
        let curr_sun_alt = 4.0; // Drops below obstacle (5.0)
        let curr_sun_azimuth = 180.0;
        let curr_obs = 5.0;
        let minute_offset = 10;

        state = step_simulation(
            state,
            minute_offset,
            current_ms,
            curr_sun_alt,
            curr_sun_azimuth,
            curr_obs,
            10,
        );

        // Sunset should be recorded
        // 日没時刻が記録されていること
        assert_eq!(state.sunset_minutes, 10.0);
        assert_eq!(state.sunset_time_unix, (current_ms / MS_PER_SECOND).floor());

        // Sunrise should NOT be recorded yet
        // 日の出はまだ記録されていないこと
        assert_eq!(state.sunrise_time_unix, -1.0);

        // Sun path should be recorded (meets all conditions)
        // 軌道情報が記録されていること
        assert_eq!(state.sun_path.len(), 1);
        assert_eq!(state.sun_path[0].altitude, 4.0);

        // Prev values should be updated
        // 状態が更新されていること
        assert_eq!(state.prev_alt, 4.0);
        assert_eq!(state.prev_obs, 5.0);
    }
}
