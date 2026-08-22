use crate::core::{
    azimuth_profile::TerrainAzimuthProfileWasm, simulate_sun_path::SunPathPointWasm,
};

#[derive(Clone, Debug)]
pub struct MoonShadowResultWasm {
    pub is_polar: bool,
    pub moonset_time_unix: f64,
    pub minutes_to_moonset: f64,
    pub moonrise_time_unix: f64,
    pub minutes_to_moonrise: f64,
    pub azimuth_profiles: Vec<TerrainAzimuthProfileWasm>,
    pub moon_path: Vec<SunPathPointWasm>,
    pub fraction: f64,
    pub phase: f64,
}

impl MoonShadowResultWasm {
    pub fn pack_into_buffer(&self, buffer: &mut Vec<f64>) {
        buffer.push(if self.is_polar { 1.0 } else { 0.0 });
        buffer.push(self.moonset_time_unix);
        buffer.push(self.minutes_to_moonset);
        buffer.push(self.moonrise_time_unix);
        buffer.push(self.minutes_to_moonrise);
        buffer.push(self.azimuth_profiles.len() as f64);
        buffer.push(self.moon_path.len() as f64);
        buffer.push(self.fraction);
        buffer.push(self.phase);

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
        for sp in &self.moon_path {
            buffer.push(sp.time);
            buffer.push(sp.azimuth);
            buffer.push(sp.altitude);
        }
    }
}
