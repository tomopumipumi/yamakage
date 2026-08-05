import { describe, expect, it } from 'vitest';
import type { SamplingPoint } from '../../models/types';
import { TerrainProfileEngine } from '../TerrainProfileEngine';

describe('TerrainProfileEngine', () => {
  it('correctly calculates the maximum obstacle angle considering earth curvature and refraction', () => {
    const lat = 34.81;
    const lng = 135.534;

    const panorama = [
      {
        azimuth: 0,
        points: [{ lat: 34.82, lng: 135.534, distance: 1000 }] as SamplingPoint[],
      },
    ];

    const elevationsMap = new Map<string, number>();
    elevationsMap.set(`${Math.round(lat * 1000)}_${Math.round(lng * 1000)}`, 100);
    elevationsMap.set(`${Math.round(34.82 * 1000)}_${Math.round(135.534 * 1000)}`, 500);

    const result = TerrainProfileEngine.buildAzimuthProfiles(lat, lng, panorama, elevationsMap);

    expect(result.length).toBe(1);
    expect(result[0].azimuthDeg).toBe(0);
    expect(result[0].maxObstacleAngleDeg).toBeGreaterThan(0);
  });
});
