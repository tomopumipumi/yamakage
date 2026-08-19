use crate::core::{
    azimuth_profile::TerrainAzimuthProfileWasm, simulate_sun_path::SunPathPointWasm,
};

#[derive(Clone, Debug)]
pub struct ShadowResultWasm {
    pub is_polar: bool,
    pub sunset_time_unix: f64,
    pub minutes_to_sunset: f64,
    pub sunrise_time_unix: f64,
    pub minutes_to_sunrise: f64,
    pub azimuth_profiles: Vec<TerrainAzimuthProfileWasm>,
    pub sun_path: Vec<SunPathPointWasm>,
}

impl ShadowResultWasm {
    pub fn pack_into_buffer(&self, buffer: &mut Vec<f64>) {
        buffer.push(if self.is_polar { 1.0 } else { 0.0 });
        buffer.push(self.sunset_time_unix);
        buffer.push(self.minutes_to_sunset);
        buffer.push(self.sunrise_time_unix);
        buffer.push(self.minutes_to_sunrise);
        buffer.push(self.azimuth_profiles.len() as f64);
        buffer.push(self.sun_path.len() as f64);
        buffer.push(0.0);

        for p in &self.azimuth_profiles {
            buffer.push(p.azimuth_deg);
            buffer.push(p.max_obstacle_angle_deg);
            if let Some(pt) = &p.highest_point {
                buffer.push(pt.lat);
                buffer.push(pt.lng);
                buffer.push(p.highest_altitude);
                buffer.push(p.distance);
            } else {
                buffer.push(f64::NAN);
                buffer.push(f64::NAN);
                buffer.push(0.0);
                buffer.push(0.0);
            }
        }

        for sp in &self.sun_path {
            buffer.push(sp.time);
            buffer.push(sp.azimuth);
            buffer.push(sp.altitude);
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::core::azimuth_profile::CoordinateWasm;

    use super::*;

    #[test]
    fn test_pack_into_buffer() {
        let mut buffer = Vec::new();
        let result = ShadowResultWasm {
            is_polar: false,
            sunset_time_unix: 1000.0,
            minutes_to_sunset: 10.0,
            sunrise_time_unix: 2000.0,
            minutes_to_sunrise: 20.0,
            azimuth_profiles: vec![TerrainAzimuthProfileWasm {
                azimuth_deg: 90.0,
                max_obstacle_angle_deg: 5.0,
                highest_point: Some(CoordinateWasm {
                    lat: 35.1,
                    lng: 135.1,
                }),
                highest_altitude: 100.0,
                distance: 1000.0,
            }],
            sun_path: vec![SunPathPointWasm {
                time: 1500.0,
                azimuth: 180.0,
                altitude: 45.0,
            }],
        };

        result.pack_into_buffer(&mut buffer);

        assert_eq!(buffer.len(), 17);

        // Header
        assert_eq!(buffer[0], 0.0); // is_polar
        assert_eq!(buffer[1], 1000.0); // sunset
        assert_eq!(buffer[5], 1.0); // num_profiles
        assert_eq!(buffer[6], 1.0); // num_sun_path

        // Profile
        assert_eq!(buffer[8], 90.0); // azimuth_deg
        assert_eq!(buffer[9], 5.0); // max_obstacle_angle_deg
        assert_eq!(buffer[10], 35.1); // lat
        assert_eq!(buffer[11], 135.1); // lng
        assert_eq!(buffer[12], 100.0); // highest_altitude
        assert_eq!(buffer[13], 1000.0); // distance (追加)

        // Sun path (インデックスが1つずつ後ろにずれる)
        assert_eq!(buffer[14], 1500.0); // time
        assert_eq!(buffer[15], 180.0); // azimuth
        assert_eq!(buffer[16], 45.0); // altitude
    }
}
