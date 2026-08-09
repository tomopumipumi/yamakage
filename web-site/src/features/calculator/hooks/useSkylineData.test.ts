import { renderHook } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import type { SunPathPoint, TerrainAzimuthProfile } from '../api/calculateShadow';
import { useSkylineData } from './useSkylineData';

describe('useSkylineData', () => {
  it('returns an empty array when profiles are empty', () => {
    const { result } = renderHook(() => useSkylineData([], []));
    expect(result.current).toEqual([]);
  });

  it('correctly merges and interpolates terrain data and sun path data', () => {
    // Mock data: 10 deg elevation at 0 deg, 20 deg elevation at 180 deg, 10 deg elevation at 360 deg
    const azimuthProfiles: TerrainAzimuthProfile[] = [
      { azimuthDeg: 0, maxObstacleAngleDeg: 10 },
      { azimuthDeg: 180, maxObstacleAngleDeg: 20 },
      { azimuthDeg: 360, maxObstacleAngleDeg: 10 },
    ];
    // Sun data: Sun is located at 90 deg azimuth (altitude 45 deg)
    const sunPath: SunPathPoint[] = [{ time: 1000, azimuth: 90, altitude: 45 }];

    const { result } = renderHook(() => useSkylineData(azimuthProfiles, sunPath));
    const data = result.current;

    expect(data.length).toBeGreaterThan(0);

    // Verify that sun data is inserted
    const sunPoint = data.find((p) => p.azimuth === 90 && p.sun !== undefined);
    expect(sunPoint).toBeDefined();
    expect(sunPoint?.sun).toBe(45);

    // Verify that the terrain elevation angle is linearly interpolated
    // The terrain elevation angle at 90 deg, halfway between 0 deg (10) and 180 deg (20), should be 15
    expect(sunPoint?.terrain).toBeCloseTo(15);
  });
});
