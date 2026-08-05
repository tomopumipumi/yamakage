import type {
  ShadowCalculationResult,
  SunriseCalculationResult,
  TerrainAzimuthProfile,
} from '../models/types';
import { SunPositionEngine } from './SunPositionEngine';

const getInterpolatedObstacleAngle = (
  azimuthProfiles: TerrainAzimuthProfile[],
  azimuth: number,
) => {
  if (azimuthProfiles.length === 0) return -0.833;
  if (azimuthProfiles.length === 1) return azimuthProfiles[0].maxObstacleAngleDeg;

  const sorted = [...azimuthProfiles].sort((a, b) => a.azimuthDeg - b.azimuthDeg);

  let left = sorted[sorted.length - 1];
  let right = sorted[0];

  for (let i = 0; i < sorted.length - 1; i++) {
    if (azimuth >= sorted[i].azimuthDeg && azimuth <= sorted[i + 1].azimuthDeg) {
      left = sorted[i];
      right = sorted[i + 1];
      break;
    }
  }

  if (left.azimuthDeg === right.azimuthDeg) return left.maxObstacleAngleDeg;

  let diffRightLeft = right.azimuthDeg - left.azimuthDeg;
  if (diffRightLeft < 0) diffRightLeft += 360;

  let diffAzimuthLeft = azimuth - left.azimuthDeg;
  if (diffAzimuthLeft < 0) diffAzimuthLeft += 360;

  const ratio = diffAzimuthLeft / diffRightLeft;
  return left.maxObstacleAngleDeg + ratio * (right.maxObstacleAngleDeg - left.maxObstacleAngleDeg);
};

export const ShadowCalculationEngine = {
  calculateTrueSunset: (
    lat: number,
    lng: number,
    startTime: Date,
    azimuthProfiles: TerrainAzimuthProfile[],
  ): ShadowCalculationResult => {
    const checkTime = new Date(startTime.getTime());

    const prevSunPos = SunPositionEngine.getPosition(checkTime, lat, lng);
    let prevAltitude = prevSunPos.altitudeDeg;
    let prevObstacleAngle = getInterpolatedObstacleAngle(azimuthProfiles, prevSunPos.azimuthDeg);

    for (let i = 1; i <= 2880; i++) {
      checkTime.setTime(startTime.getTime() + i * 60000);
      const sunPos = SunPositionEngine.getPosition(checkTime, lat, lng);
      const obstacleAngle = getInterpolatedObstacleAngle(azimuthProfiles, sunPos.azimuthDeg);

      if (prevAltitude >= prevObstacleAngle && sunPos.altitudeDeg < obstacleAngle) {
        return { minutesToShadow: i, shadowTimeUnix: Math.floor(checkTime.getTime() / 1000) };
      }

      prevAltitude = sunPos.altitudeDeg;
      prevObstacleAngle = obstacleAngle;
    }
    return { minutesToShadow: 0, shadowTimeUnix: -1 };
  },

  calculateTrueSunrise: (
    lat: number,
    lng: number,
    startTime: Date,
    azimuthProfiles: TerrainAzimuthProfile[],
  ): SunriseCalculationResult => {
    const checkTime = new Date(startTime.getTime());

    const prevSunPos = SunPositionEngine.getPosition(checkTime, lat, lng);
    let prevAltitude = prevSunPos.altitudeDeg;
    let prevObstacleAngle = getInterpolatedObstacleAngle(azimuthProfiles, prevSunPos.azimuthDeg);

    for (let i = 1; i <= 2880; i++) {
      checkTime.setTime(startTime.getTime() + i * 60000);
      const sunPos = SunPositionEngine.getPosition(checkTime, lat, lng);
      const obstacleAngle = getInterpolatedObstacleAngle(azimuthProfiles, sunPos.azimuthDeg);

      if (prevAltitude <= prevObstacleAngle && sunPos.altitudeDeg > obstacleAngle) {
        return { minutesToSunrise: i, sunriseTimeUnix: Math.floor(checkTime.getTime() / 1000) };
      }

      prevAltitude = sunPos.altitudeDeg;
      prevObstacleAngle = obstacleAngle;
    }
    return { minutesToSunrise: 0, sunriseTimeUnix: -1 };
  },
};
