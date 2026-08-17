#[cfg(test)]
mod tests {
    use crate::{
        io::tile_decoder::{calc_elevation_from_rgb, decode_and_store_elevations},
        memory::arena::SamplingArena,
    };

    use png::{BitDepth, ColorType, Encoder};

    // --------------------------------------------------------------------
    // Pure function tests (RGB to Elevation)
    // 純粋関数のテスト (RGBから標高への変換)
    // --------------------------------------------------------------------
    #[test]
    fn test_calc_elevation_from_rgb() {
        // Base point (0m): (128, 0, 0)
        // 基準点 (0m): (128, 0, 0)
        assert_eq!(calc_elevation_from_rgb(128, 0, 0), 0.0);

        // High altitude (1024m): (132, 0, 0)
        // 高所 (1024m): (132, 0, 0)
        assert_eq!(calc_elevation_from_rgb(132, 0, 0), 1024.0);

        // Rounding up test (0.5m -> 1m)
        // 四捨五入のテスト (0.5m -> 1m)
        assert_eq!(calc_elevation_from_rgb(128, 0, 128), 1.0);

        // Negative altitude clipping (-32768m -> 0m)
        // 海抜マイナス値のクリップ処理 (-32768m -> 0m)
        assert_eq!(calc_elevation_from_rgb(0, 0, 0), 0.0);
    }

    // --------------------------------------------------------------------
    // Helper: Generate dummy PNG binary dynamically
    // ヘルパー: ダミーPNGバイナリの動的生成
    // --------------------------------------------------------------------
    fn create_dummy_png(width: u32, height: u32, color_type: ColorType, data: &[u8]) -> Vec<u8> {
        let mut buf = Vec::new();
        {
            let mut encoder = Encoder::new(&mut buf, width, height);
            encoder.set_color(color_type);
            encoder.set_depth(BitDepth::Eight);
            let mut writer = encoder.write_header().unwrap();
            writer.write_image_data(data).unwrap();
        }
        buf
    }

    // --------------------------------------------------------------------
    // I/O Integration tests (Decoding and mapping to Arena)
    // I/O統合テスト (デコードとアリーナへのマッピング)
    // --------------------------------------------------------------------
    #[test]
    fn test_decode_and_store_elevations_success() {
        let mut arena = SamplingArena::new();
        arena.elevations = vec![0.0; 2];
        let mut center_elevation = 0.0;

        // 2x2 RGB Image (12 bytes)
        // (0,0):0m, (1,0):1m, (0,1):10m, (1,1):clip to 0m
        let image_data: [u8; 12] = [128, 0, 0, 128, 1, 0, 128, 10, 0, 0, 0, 0];
        let png_bytes = create_dummy_png(2, 2, ColorType::Rgb, &image_data);

        // points_data: flat array of [js_idx, px, py]
        let points_data: [u32; 9] = [
            0, 1, 0, // js_idx 0 (center) -> (1,0) = 1m
            1, 0, 1, // js_idx 1 (arena[0]) -> (0,1) = 10m
            2, 1, 1, // js_idx 2 (arena[1]) -> (1,1) = 0m
        ];

        let success = decode_and_store_elevations(
            &png_bytes,
            &points_data,
            3,
            &mut arena,
            &mut center_elevation,
        );

        assert!(success);
        assert_eq!(center_elevation, 1.0);
        assert_eq!(arena.elevations[0], 10.0);
        assert_eq!(arena.elevations[1], 0.0);
    }

    #[test]
    fn test_decode_invalid_png_fails_gracefully() {
        let mut arena = SamplingArena::new();
        let mut center = 0.0;

        // Pass junk bytes / でたらめなバイト列を渡す
        let junk_bytes = [0xFF, 0x00, 0xAA, 0xBB];

        let success = decode_and_store_elevations(&junk_bytes, &[], 0, &mut arena, &mut center);

        // Should return false without panicking / パニックせずfalseを返すこと
        assert!(!success);
    }

    #[test]
    fn test_decode_out_of_bounds_pixels() {
        let mut arena = SamplingArena::new();
        let mut center = 0.0;

        // 1x1 RGB Image (1024m)
        let image_data: [u8; 3] = [132, 0, 0];
        let png_bytes = create_dummy_png(1, 1, ColorType::Rgb, &image_data);

        // Access out of bounds (10, 10) / 枠外の座標(10, 10)にアクセス
        let points_data: [u32; 3] = [0, 10, 10];

        let success =
            decode_and_store_elevations(&png_bytes, &points_data, 1, &mut arena, &mut center);

        assert!(success);
        // Fallback to 0.0 without out-of-bounds error / 範囲外エラーにならず0.0にフォールバックすること
        assert_eq!(center, 0.0);
    }
}
