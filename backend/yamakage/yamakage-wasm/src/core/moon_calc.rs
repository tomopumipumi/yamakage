use astro::{atmos, lunar, sun, time};
use std::f64::consts::PI;

const RAD: f64 = PI / 180.0;
const AU_IN_KM: f64 = 149597870.7; // 1天文単位(AU)のキロメートル換算

/// Represents the calculated position of the moon in the sky.
/// 計算された天球上での月の位置を表す構造体。
pub struct MoonPosition {
    /// Azimuth angle of the moon in degrees (measured clockwise from North).
    /// 月の方位角（度）。北を基準として時計回りに測定されます。
    pub azimuth_deg: f64,

    /// Altitude (elevation) angle of the moon in degrees above the horizon.
    /// 月の高度・仰角（度）。地平線を0度として測定されます。
    pub altitude_deg: f64,

    /// Distance from the center of the Earth to the center of the Moon in kilometers.
    /// 地球の中心から月の中心までの距離（キロメートル）。
    #[allow(dead_code)]
    pub distance_km: f64,
}

/// Represents the illuminated fraction, phase, and angle of the moon.
/// 月の輝面比（照度）、位相（月齢）、および傾き角を表す構造体。
pub struct MoonIllumination {
    /// Illuminated fraction of the moon's disk (0.0 to 1.0).
    /// 月の輝面比（照度）。0.0（新月）から 1.0（満月）の範囲で表されます。
    pub fraction: f64,

    /// Phase of the moon (0.0 to 1.0).
    /// 月の位相（月齢）。0.0（新月）から始まり、0.5（満月）を経て 1.0（次の新月）までの範囲で表されます。
    pub phase: f64,

    /// The angle of the moon's illuminated limb.
    /// 月の光っている側の傾き角。
    #[allow(dead_code)]
    pub angle: f64,
}

/// Calculates the Julian Date (JD) from a Unix timestamp in milliseconds.
/// Unixタイムスタンプ（ミリ秒）からユリウス日（JD）を計算します。
fn to_jd(timestamp_ms: f64) -> f64 {
    2440587.5 + (timestamp_ms / 86400000.0)
}

/// Computes an approximate value of Delta T (ΔT) for the Julian day.
/// ユリウス日に対してΔT（地球の自転の遅れによる補正値）を取得します。
fn get_delta_t(jd: f64) -> f64 {
    // astro::time モジュールを利用して日付を取得し、そこからDelta Tを算出
    if let Ok((year, month, _)) = time::date_frm_julian_day(jd) {
        time::delta_t(year as i32, month)
    } else {
        69.0 // 取得失敗時のフォールバック値 (近年の平均的なΔT)
    }
}

/// Calculates the moon's azimuth, altitude, and distance for a given time and geographic location.
/// 指定された時刻と位置における月の方位角、高度、および距離を計算します。
pub fn get_moon_position(timestamp_ms: f64, lat: f64, lng: f64) -> MoonPosition {
    let jd = to_jd(timestamp_ms);
    let delta_t = get_delta_t(jd);
    let jde = time::julian_ephemeris_day(jd, delta_t);
    let t = time::julian_cent(jde);

    // =============================================================
    // astro クレートを利用した月の黄道座標と距離の計算
    // =============================================================
    let (moon_ecl, distance_km) = lunar::geocent_ecl_pos(jde);
    let moon_long = moon_ecl.long; // 月の黄経
    let moon_lat = moon_ecl.lat; // 月の黄緯

    // 黄道傾斜角の計算
    let ecliptic = (23.439291 - 0.0130042 * t) * RAD;

    // 黄道座標から赤道座標（赤経・赤緯）へ変換
    let moon_ra =
        (moon_long.sin() * ecliptic.cos() - moon_lat.tan() * ecliptic.sin()).atan2(moon_long.cos());
    let moon_dec = (moon_lat.sin() * ecliptic.cos()
        + moon_lat.cos() * ecliptic.sin() * moon_long.sin())
    .asin();

    // =============================================================
    // 観測地に基づく地平座標(高度・方位角)への変換と大気差補正
    // =============================================================
    let phi = lat * RAD;
    let lw = -lng * RAD;

    // astro クレートを利用して平均恒星時を取得
    let mn_sidr = time::mn_sidr(jd);
    let local_sidr = mn_sidr - lw;
    let hour_angle = local_sidr - moon_ra;

    // 高度と方位角の計算
    let mut h = (phi.sin() * moon_dec.sin() + phi.cos() * moon_dec.cos() * hour_angle.cos()).asin();
    let az = hour_angle
        .sin()
        .atan2(hour_angle.cos() * phi.sin() - moon_dec.tan() * phi.cos());

    // 方位角を北を0度として時計回りに補正し、0~360度に収める
    let azimuth_rad = az + PI;
    let azimuth_deg = (azimuth_rad / RAD + 360.0) % 360.0;

    // astro クレートを利用した大気差補正 (水平線上にある場合のみ適用)
    if h > -0.05 {
        h += atmos::refrac_frm_true_alt(h);
    }

    MoonPosition {
        azimuth_deg,
        altitude_deg: h / RAD,
        distance_km,
    }
}

/// Calculates the moon's illuminated fraction, phase, and angle for a given time.
/// 指定された時刻における月の輝面比（照度）、位相（月齢）、および傾き角を計算します。
pub fn get_moon_illumination(timestamp_ms: f64) -> MoonIllumination {
    let jd = to_jd(timestamp_ms);
    let delta_t = get_delta_t(jd);
    let jde = time::julian_ephemeris_day(jd, delta_t);
    let t = time::julian_cent(jde);

    // =============================================================
    // astro クレートを利用して月と太陽の黄道座標を取得
    // =============================================================
    let (moon_ecl, moon_dist_km) = lunar::geocent_ecl_pos(jde);
    let (sun_ecl, sun_dist_au) = sun::geocent_ecl_pos(jde);

    let moon_long = moon_ecl.long;
    let moon_lat = moon_ecl.lat;
    let sun_long = sun_ecl.long;
    let sun_lat = sun_ecl.lat;

    // astro クレートを利用した輝面比(照度)の計算
    // 注意: 地球から太陽までの距離はAUをkmに変換して渡す
    let fraction = lunar::illum_frac_frm_ecl_coords(
        moon_long,
        moon_lat,
        sun_long,
        moon_dist_km,
        sun_dist_au * AU_IN_KM,
    );

    // =============================================================
    // 位相(月齢)と光っている側の傾き角の計算
    // =============================================================
    // 位相(phase)の計算: 太陽と月の黄経差から求める (0.0~1.0 に正規化)
    let mut phase = (moon_long - sun_long) / (2.0 * PI);
    phase = phase - phase.floor();
    if phase < 0.0 {
        phase += 1.0;
    }

    // 月と太陽の赤道座標を計算（傾き角の算出用）
    let ecliptic = (23.439291 - 0.0130042 * t) * RAD;

    let moon_ra =
        (moon_long.sin() * ecliptic.cos() - moon_lat.tan() * ecliptic.sin()).atan2(moon_long.cos());
    let moon_dec = (moon_lat.sin() * ecliptic.cos()
        + moon_lat.cos() * ecliptic.sin() * moon_long.sin())
    .asin();

    let sun_ra =
        (sun_long.sin() * ecliptic.cos() - sun_lat.tan() * ecliptic.sin()).atan2(sun_long.cos());
    let sun_dec =
        (sun_lat.sin() * ecliptic.cos() + sun_lat.cos() * ecliptic.sin() * sun_long.sin()).asin();

    let angle = (sun_dec.cos() * (sun_ra - moon_ra).sin()).atan2(
        sun_dec.sin() * moon_dec.cos() - sun_dec.cos() * moon_dec.sin() * (sun_ra - moon_ra).cos(),
    );

    MoonIllumination {
        fraction,
        phase,
        angle,
    }
}
