#[cfg(test)]
pub(crate) mod tests {
    use crate::{
        core::{
            constants::{DEGREES_PER_RADIAN, RADIANS_PER_DEGREE},
            terrain_sampling::{
                calc_destination_coordinate, generate_sampling_points, get_quality_configs,
            },
        },
        memory::arena::{AzimuthGroup, SamplingArena},
    };

    // Helper for floating point comparison
    // 浮動小数点数比較用のヘルパー
    fn assert_f64_eq(a: f64, b: f64) {
        assert!((a - b).abs() < 1e-6, "{} is not close to {}", a, b);
    }

    // --------------------------------------------------------------------
    // Config selection tests
    // 設定選択のテスト
    // --------------------------------------------------------------------
    #[test]
    fn test_get_quality_configs() {
        // High quality (2) / 高品質 (2)
        let config_high = get_quality_configs(2);
        assert_eq!(config_high.len(), 3);
        assert_eq!(config_high[0].start_dist, 100.0);

        // Medium quality (1) / 中品質 (1)
        let config_mid = get_quality_configs(1);
        assert_eq!(config_mid.len(), 4);

        // Fallback quality (other) / デフォルト品質 (その他)
        let config_fallback = get_quality_configs(0);
        assert_eq!(config_fallback.len(), 3);
        assert_eq!(config_fallback[2].max_dist, 30000.0);
    }

    // --------------------------------------------------------------------
    // Pure function tests (Spherical Coordinate Calculation)
    // 純粋関数のテスト (球面座標計算)
    // --------------------------------------------------------------------
    #[test]
    fn test_calc_destination_coordinate() {
        let start_lat = 0.0_f64; // Equator / 赤道
        let start_lng = 0.0_f64; // Prime Meridian / 本初子午線

        let sl_sin = start_lat.sin();
        let sl_cos = start_lat.cos();
        let start_lng_rad = start_lng * RADIANS_PER_DEGREE;

        // Move Due North (Azimuth 0) by ~111km (approx 1 degree)
        // 真北(方位角0度)へ約111km(約1度分)移動
        let az_north = 0.0_f64;
        let dist = 111195.0; // Approx 1 degree on Earth surface

        let (lat_rad, lng_rad) = calc_destination_coordinate(
            sl_sin,
            sl_cos,
            start_lng_rad,
            az_north.sin(),
            az_north.cos(),
            dist,
        );

        // Latitude should increase by approx 1 degree, longitude remains 0
        // 緯度が約1度増加し、経度は0のままとなること
        let lat_deg = lat_rad * DEGREES_PER_RADIAN;
        let lng_deg = lng_rad * DEGREES_PER_RADIAN;

        assert!(lat_deg > 0.99 && lat_deg < 1.01);
        assert_f64_eq(lng_deg, 0.0);
    }

    #[test]
    fn test_calc_destination_coordinate_longitude_wrap_around() {
        let start_lat = 0.0_f64; // Equator / 赤道

        let sl_sin = start_lat.sin();
        let sl_cos = start_lat.cos();
        let dist = 111195.0; // Approx 1 degree on Earth surface / 地表での約1度分の距離

        // --- Case 1: Crossing the antimeridian going East (+180 deg) ---
        // --- ケース1: 東へ進み、日付変更線(+180度)を超える場合 ---
        let start_lng_east = 179.9_f64;
        let start_lng_east_rad = start_lng_east * RADIANS_PER_DEGREE;

        // Azimuth 90 = Due East / 方位角 90度 = 真東
        let az_east = 90.0_f64 * RADIANS_PER_DEGREE;

        let (lat_rad_1, lng_rad_1) = calc_destination_coordinate(
            sl_sin,
            sl_cos,
            start_lng_east_rad,
            az_east.sin(),
            az_east.cos(),
            dist,
        );

        let lat_deg_1 = lat_rad_1 * DEGREES_PER_RADIAN;
        let lng_deg_1 = lng_rad_1 * DEGREES_PER_RADIAN;

        // Latitude should remain 0 / 緯度は0度のまま
        assert_f64_eq(lat_deg_1, 0.0);
        // Longitude should wrap from 180.9 to -179.1 / 経度は 180.9度から -179.1度 へラップアラウンドされること
        assert!(lng_deg_1 > -179.2 && lng_deg_1 < -179.0);

        // --- Case 2: Crossing the antimeridian going West (-180 deg) ---
        // --- ケース2: 西へ進み、日付変更線(-180度)を下回る場合 ---
        let start_lng_west = -179.9_f64;
        let start_lng_west_rad = start_lng_west * RADIANS_PER_DEGREE;

        // Azimuth 270 = Due West / 方位角 270度 = 真西
        let az_west = 270.0_f64 * RADIANS_PER_DEGREE;

        let (lat_rad_2, lng_rad_2) = calc_destination_coordinate(
            sl_sin,
            sl_cos,
            start_lng_west_rad,
            az_west.sin(),
            az_west.cos(),
            dist,
        );

        let lat_deg_2 = lat_rad_2 * DEGREES_PER_RADIAN;
        let lng_deg_2 = lng_rad_2 * DEGREES_PER_RADIAN;

        // Latitude should remain 0 / 緯度は0度のまま
        assert_f64_eq(lat_deg_2, 0.0);
        // Longitude should wrap from -180.9 to 179.1 / 経度は -180.9度から +179.1度 へラップアラウンドされること
        assert!(lng_deg_2 > 179.0 && lng_deg_2 < 179.2);
    }

    // --------------------------------------------------------------------
    // Integration tests (Sampling Points Generation)
    // 統合テスト (サンプリングポイントの生成)
    // --------------------------------------------------------------------
    #[test]
    fn test_generate_sampling_points() {
        let mut arena = SamplingArena::new();

        // Insert dummy data to test `arena.clear()`
        // `arena.clear()` の動作確認のためダミーデータを挿入
        arena.lats.push(99.9);
        arena.groups.push(AzimuthGroup {
            azimuth_deg: 99.0,
            range: 0..1,
        });

        // Generate points with 90 degree steps (4 directions)
        // 90度ステップ(4方向)でポイントを生成
        generate_sampling_points(&mut arena, 35.0, 135.0, 90.0, 0);

        // 360 / 90 = 4 azimuth groups should be generated
        // 360 / 90 = 4 つの方位グループが生成されること
        assert_eq!(arena.groups.len(), 4);
        assert_eq!(arena.groups[0].azimuth_deg, 0.0);
        assert_eq!(arena.groups[1].azimuth_deg, 90.0);
        assert_eq!(arena.groups[2].azimuth_deg, 180.0);
        assert_eq!(arena.groups[3].azimuth_deg, 270.0);

        // Points should be distributed evenly among groups
        // 各グループにポイントが割り振られていること
        let points_per_group = arena.groups[0].range.len();
        assert!(points_per_group > 0);
        assert_eq!(arena.lats.len(), points_per_group * 4);

        // Ensure all arrays are synchronized and resized correctly
        // 全ての配列の長さが同期され、リサイズされていること
        assert_eq!(arena.lats.len(), arena.lngs.len());
        assert_eq!(arena.lats.len(), arena.distances.len());
        assert_eq!(arena.lats.len(), arena.elevations.len());

        // Elevation array should be initialized to 0.0
        // 標高配列は 0.0 で初期化されていること
        assert_eq!(arena.elevations[0], 0.0);
    }
}
