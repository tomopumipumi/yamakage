import type {
  ShadowCalculationResult,
  SunriseCalculationResult,
  TerrainAzimuthProfile,
} from '../models/types';
import { SunPositionEngine } from './SunPositionEngine';

const SUN_RADIUS_DEG = 0.266;

const getInterpolatedObstacleAngle = (
  azimuthProfiles: TerrainAzimuthProfile[],
  azimuth: number,
) => {
  if (azimuthProfiles.length === 0) return -0.833;
  if (azimuthProfiles.length === 1) return azimuthProfiles[0].maxObstacleAngleDeg;

  const sorted = [...azimuthProfiles].sort((a, b) => a.azimuthDeg - b.azimuthDeg);

  const rightIndex = sorted.findIndex((p) => p.azimuthDeg > azimuth);

  const left = rightIndex <= 0 ? sorted[sorted.length - 1] : sorted[rightIndex - 1];
  const right = rightIndex === -1 ? sorted[0] : sorted[rightIndex];

  if (left.azimuthDeg === right.azimuthDeg) return left.maxObstacleAngleDeg;

  const diffRightLeft = (right.azimuthDeg - left.azimuthDeg + 360) % 360;
  const diffAzimuthLeft = (azimuth - left.azimuthDeg + 360) % 360;

  const ratio = diffAzimuthLeft / diffRightLeft;
  return left.maxObstacleAngleDeg + ratio * (right.maxObstacleAngleDeg - left.maxObstacleAngleDeg);
};

type CrossingCondition = (
  prevAlt: number,
  prevObs: number,
  currAlt: number,
  currObs: number,
) => boolean;

const findSunCrossing = (
  lat: number,
  lng: number,
  startTime: Date,
  azimuthProfiles: TerrainAzimuthProfile[],
  isCrossing: CrossingCondition,
) => {
  const startUnix = startTime.getTime();

  const initialTime = new Date(startUnix - 720 * 60000);
  const initialSunPos = SunPositionEngine.getPosition(initialTime, lat, lng);

  let prevAltitude = initialSunPos.altitudeDeg + SUN_RADIUS_DEG;
  let prevObstacleAngle = getInterpolatedObstacleAngle(azimuthProfiles, initialSunPos.azimuthDeg);

  for (let i = -719; i <= 2880; i++) {
    const currentUnix = startUnix + i * 60000;
    const checkTime = new Date(currentUnix);
    const sunPos = SunPositionEngine.getPosition(checkTime, lat, lng);
    const obstacleAngle = getInterpolatedObstacleAngle(azimuthProfiles, sunPos.azimuthDeg);

    const sunTopAlt = sunPos.altitudeDeg + SUN_RADIUS_DEG;

    if (i > 0 && isCrossing(prevAltitude, prevObstacleAngle, sunTopAlt, obstacleAngle)) {
      return { minutes: i, timeUnix: Math.floor(currentUnix / 1000) };
    }

    prevAltitude = sunTopAlt;
    prevObstacleAngle = obstacleAngle;
  }
  return { minutes: 0, timeUnix: -1 };
};

export const ShadowCalculationEngine = {
  calculateTrueSunset: (
    lat: number,
    lng: number,
    startTime: Date,
    azimuthProfiles: TerrainAzimuthProfile[],
  ): ShadowCalculationResult => {
    const result = findSunCrossing(
      lat,
      lng,
      startTime,
      azimuthProfiles,
      (prevAlt, prevObs, currAlt, currObs) => prevAlt >= prevObs && currAlt < currObs,
    );

    return { minutesToShadow: result.minutes, shadowTimeUnix: result.timeUnix };
  },

  calculateTrueSunrise: (
    lat: number,
    lng: number,
    startTime: Date,
    azimuthProfiles: TerrainAzimuthProfile[],
  ): SunriseCalculationResult => {
    const result = findSunCrossing(
      lat,
      lng,
      startTime,
      azimuthProfiles,
      (prevAlt, prevObs, currAlt, currObs) => prevAlt <= prevObs && currAlt > currObs,
    );

    return { minutesToSunrise: result.minutes, sunriseTimeUnix: result.timeUnix };
  },
};
