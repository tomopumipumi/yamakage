export interface Coordinate {
  lat: number;
  lng: number;
}

export interface SamplingPoint extends Coordinate {
  distance: number;
}

export interface ProfilePoint {
  distance: number;
  altitude: number;
}

export interface SunPosition {
  altitudeRad: number;
  azimuthRad: number;
  altitudeDeg: number;
  azimuthDeg: number;
}

export interface ShadowCalculationResult {
  minutesToShadow: number;
  shadowTimeUnix: number;
}

export interface SunriseCalculationResult {
  minutesToSunrise: number;
  sunriseTimeUnix: number;
}

export interface TerrainAzimuthProfile {
  azimuthDeg: number;
  maxObstacleAngleDeg: number;
}
