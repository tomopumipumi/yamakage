import { useMemo } from 'react';
import type { SunPathPoint, TerrainAzimuthProfile } from '../api/calculateShadow';

export interface SkylineChartPoint {
  azimuth: number;
  sun?: number;
  terrain: number;
  isTerrainBase?: boolean;
}

export const useSkylineData = (
  azimuthProfiles: TerrainAzimuthProfile[],
  sunPath: SunPathPoint[],
): SkylineChartPoint[] => {
  return useMemo(() => {
    if (!azimuthProfiles.length) return [];

    const dataPoints: { azimuth: number; sun?: number; isTerrainBase?: boolean }[] = [];

    for (let az = 0; az <= 360; az += 2) {
      dataPoints.push({ azimuth: az, isTerrainBase: true });
    }

    if (sunPath && sunPath.length > 0) {
      sunPath.forEach((sun) => {
        dataPoints.push({ azimuth: sun.azimuth, sun: sun.altitude });
      });
    }

    dataPoints.sort((a, b) => a.azimuth - b.azimuth);

    const sortedTerrain = [...azimuthProfiles].sort((a, b) => a.azimuthDeg - b.azimuthDeg);

    return dataPoints.map((pt) => {
      const az = pt.azimuth;
      let left = sortedTerrain[sortedTerrain.length - 1];
      let right = sortedTerrain[0];

      for (let i = 0; i < sortedTerrain.length - 1; i++) {
        if (az >= sortedTerrain[i].azimuthDeg && az <= sortedTerrain[i + 1].azimuthDeg) {
          left = sortedTerrain[i];
          right = sortedTerrain[i + 1];
          break;
        }
      }

      let diffRL = right.azimuthDeg - left.azimuthDeg;
      if (diffRL < 0) diffRL += 360;
      let diffAL = az - left.azimuthDeg;
      if (diffAL < 0) diffAL += 360;

      const ratio = diffRL === 0 ? 0 : diffAL / diffRL;
      const terrainAlt =
        left.maxObstacleAngleDeg + ratio * (right.maxObstacleAngleDeg - left.maxObstacleAngleDeg);

      return {
        ...pt,
        terrain: Math.max(0, terrainAlt),
      };
    });
  }, [azimuthProfiles, sunPath]);
};
