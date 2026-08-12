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
    elevationsMap.set(`${Math.round(lat * 100000)}_${Math.round(lng * 100000)}`, 100);
    elevationsMap.set(`${Math.round(34.82 * 100000)}_${Math.round(135.534 * 100000)}`, 500);

    const result = TerrainProfileEngine.buildAzimuthProfiles(lat, lng, panorama, elevationsMap);

    expect(result.length).toBe(1);
    expect(result[0].azimuthDeg).toBe(0);
    expect(result[0].maxObstacleAngleDeg).toBeGreaterThan(0);
  });

  it('skips missing elevation data (undefined) gracefully', () => {
    const lat = 34.81;
    const lng = 135.534;

    const panorama = [
      {
        azimuth: 0,
        points: [
          { lat: 34.82, lng: 135.534, distance: 1000 },
          { lat: 34.83, lng: 135.534, distance: 2000 },
        ] as SamplingPoint[],
      },
    ];

    const elevationsMap = new Map<string, number>();
    elevationsMap.set(`${Math.round(lat * 100000)}_${Math.round(lng * 100000)}`, 100);
    // Assume data for 34.82 is missing (undefined)
    elevationsMap.set(`${Math.round(34.83 * 100000)}_${Math.round(135.534 * 100000)}`, 500);

    const result = TerrainProfileEngine.buildAzimuthProfiles(lat, lng, panorama, elevationsMap);

    expect(result.length).toBe(1);
    expect(result[0].maxObstacleAngleDeg).toBeGreaterThan(0);
  });

  it('adopts the maximum angle when a higher mountain is behind a lower one', () => {
    const lat = 34.81;
    const lng = 135.534;

    const panorama = [
      {
        azimuth: 0,
        points: [
          { lat: 34.815, lng: 135.534, distance: 1000 }, // Lower mountain in front
          { lat: 34.85, lng: 135.534, distance: 5000 }, // Higher mountain behind
        ] as SamplingPoint[],
      },
    ];

    const elevationsMap = new Map<string, number>();
    elevationsMap.set(`${Math.round(lat * 100000)}_${Math.round(lng * 100000)}`, 100);
    elevationsMap.set(`${Math.round(34.815 * 100000)}_${Math.round(135.534 * 100000)}`, 150); // Elevation angle approx. 2.8 degrees
    elevationsMap.set(`${Math.round(34.85 * 100000)}_${Math.round(135.534 * 100000)}`, 2000); // Elevation angle approx. 21 degrees

    const result = TerrainProfileEngine.buildAzimuthProfiles(lat, lng, panorama, elevationsMap);

    expect(result[0].maxObstacleAngleDeg).toBeGreaterThan(20);
  });

  it('returns default initial angle (-0.833) when positioned at the peak and all surrounding points are lower', () => {
    const lat = 34.81;
    const lng = 135.534;

    const panorama = [
      {
        azimuth: 0,
        points: [{ lat: 34.82, lng: 135.534, distance: 1000 }] as SamplingPoint[],
      },
    ];

    const elevationsMap = new Map<string, number>();
    elevationsMap.set(`${Math.round(lat * 100000)}_${Math.round(lng * 100000)}`, 3000); // Located at the peak
    elevationsMap.set(`${Math.round(34.82 * 100000)}_${Math.round(135.534 * 100000)}`, 1000); // Surrounding terrain is lower

    const result = TerrainProfileEngine.buildAzimuthProfiles(lat, lng, panorama, elevationsMap);

    expect(result[0].maxObstacleAngleDeg).toBe(-0.833);
  });
});
