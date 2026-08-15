use crate::arena::SamplingArena;
use std::io::Cursor;

pub fn decode_and_store_elevations(
    png_data: &[u8],
    points_data: &[u32],
    num_points: usize,
    arena: &mut SamplingArena,
    center_elevation: &mut f64,
) -> bool {
    let cursor = Cursor::new(png_data);
    let decoder = png::Decoder::new(cursor);

    let mut reader = match decoder.read_info() {
        Ok(r) => r,
        Err(_) => return false,
    };

    let mut buf = vec![0; reader.output_buffer_size().unwrap()];
    let info = match reader.next_frame(&mut buf) {
        Ok(i) => i,
        Err(_) => return false,
    };

    let width = info.width as usize;
    let channels = match info.color_type {
        png::ColorType::Rgb => 3,
        png::ColorType::Rgba => 4,
        _ => return false,
    };

    for i in 0..num_points {
        let js_idx = points_data[i * 3] as usize;
        let px = points_data[i * 3 + 1] as usize;
        let py = points_data[i * 3 + 2] as usize;

        let pixel_idx = (py * width + px) * channels;
        let mut elevation = 0.0;

        if pixel_idx + 2 < buf.len() {
            let r = buf[pixel_idx] as f64;
            let g = buf[pixel_idx + 1] as f64;
            let b = buf[pixel_idx + 2] as f64;
            let mut raw_elevation = r * 256.0 + g + b / 256.0 - 32768.0;
            if raw_elevation < 0.0 {
                raw_elevation = 0.0;
            }
            elevation = raw_elevation.round();
        }

        if js_idx == 0 {
            *center_elevation = elevation;
        } else {
            let arena_idx = js_idx - 1;
            if arena_idx < arena.elevations.len() {
                arena.elevations[arena_idx] = elevation;
            }
        }
    }
    true
}
