import { useMemo } from 'react';
import type { SunPathPoint, TerrainAzimuthProfile } from '../api/calculateShadow';

export interface SkylineChartPoint {
  azimuth: number;
  sun?: number;
  terrain: number;
}

export const useSkylineData = (
  azimuthProfiles: TerrainAzimuthProfile[],
  sunPath: SunPathPoint[],
): SkylineChartPoint[] => {
  return useMemo(() => {
    if (!azimuthProfiles.length) return [];

    const pointMap = new Map<number, SkylineChartPoint & { hasTerrain: boolean }>();

    azimuthProfiles.forEach((profile) => {
      pointMap.set(profile.azimuthDeg, {
        azimuth: profile.azimuthDeg,
        terrain: Math.max(0, profile.maxObstacleAngleDeg),
        hasTerrain: true,
      });
    });

    if (sunPath && sunPath.length > 0) {
      sunPath.forEach((sun) => {
        const existing = pointMap.get(sun.azimuth);
        if (existing) {
          existing.sun = sun.altitude;
        } else {
          pointMap.set(sun.azimuth, {
            azimuth: sun.azimuth,
            sun: sun.altitude,
            terrain: 0,
            hasTerrain: false,
          });
        }
      });
    }

    const mergedData = Array.from(pointMap.values()).sort((a, b) => a.azimuth - b.azimuth);

    const sortedTerrain = [...azimuthProfiles].sort((a, b) => a.azimuthDeg - b.azimuthDeg);

    return mergedData.map((pt) => {
      if (pt.hasTerrain) {
        const { hasTerrain, ...rest } = pt;
        return rest;
      }

      let left = sortedTerrain[sortedTerrain.length - 1];
      let right = sortedTerrain[0];

      for (let i = 0; i < sortedTerrain.length - 1; i++) {
        if (
          pt.azimuth >= sortedTerrain[i].azimuthDeg &&
          pt.azimuth <= sortedTerrain[i + 1].azimuthDeg
        ) {
          left = sortedTerrain[i];
          right = sortedTerrain[i + 1];
          break;
        }
      }

      let diffRL = right.azimuthDeg - left.azimuthDeg;
      if (diffRL < 0) diffRL += 360;
      let diffAL = pt.azimuth - left.azimuthDeg;
      if (diffAL < 0) diffAL += 360;

      const ratio = diffRL === 0 ? 0 : diffAL / diffRL;
      const terrainAlt =
        left.maxObstacleAngleDeg + ratio * (right.maxObstacleAngleDeg - left.maxObstacleAngleDeg);

      const { hasTerrain, ...rest } = pt;
      return {
        ...rest,
        terrain: Math.max(0, terrainAlt),
      };
    });
  }, [azimuthProfiles, sunPath]);
};
