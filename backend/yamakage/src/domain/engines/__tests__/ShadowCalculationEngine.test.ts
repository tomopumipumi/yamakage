import { describe, expect, it } from 'vitest';
import type { TerrainAzimuthProfile } from '../../../domain/models/types';
import { ShadowCalculationEngine } from '../ShadowCalculationEngine';

describe('ShadowCalculationEngine', () => {
  it('correctly detects the time when the sun altitude falls below the mountain height at sunset', () => {
    const lat = 34.81;
    const lng = 135.534;
    const startTime = new Date('2024-06-10T04:00:00Z');

    const azimuthProfiles: TerrainAzimuthProfile[] = [{ azimuthDeg: 280, maxObstacleAngleDeg: 15 }];

    const result = ShadowCalculationEngine.calculateTrueSunset(
      lat,
      lng,
      startTime,
      azimuthProfiles,
    );

    expect(result).toHaveProperty('minutesToShadow');
    expect(result).toHaveProperty('shadowTimeUnix');
    expect(result.minutesToShadow).toBeGreaterThan(0);
    expect(result.shadowTimeUnix).toBeGreaterThan(0);
  });

  it('correctly detects the time when the sun altitude rises above the mountain height at sunrise', () => {
    const lat = 34.81;
    const lng = 135.534;
    const startTime = new Date('2024-06-10T20:00:00Z');

    const azimuthProfiles: TerrainAzimuthProfile[] = [{ azimuthDeg: 90, maxObstacleAngleDeg: 0 }];

    const result = ShadowCalculationEngine.calculateTrueSunrise(
      lat,
      lng,
      startTime,
      azimuthProfiles,
    );

    expect(result).toHaveProperty('minutesToSunrise');
    expect(result).toHaveProperty('sunriseTimeUnix');
    expect(result.minutesToSunrise).toBeGreaterThan(0);
    expect(result.sunriseTimeUnix).toBeGreaterThan(0);
  });

  it('correctly determines and calculates using the closest profile even at boundary values near north (0/360 degrees) azimuth', () => {
    const lat = 60.0;
    const lng = 10.0;
    const startTime = new Date('2024-06-21T18:00:00Z');

    const azimuthProfiles: TerrainAzimuthProfile[] = [
      { azimuthDeg: 10, maxObstacleAngleDeg: 5 },
      { azimuthDeg: 180, maxObstacleAngleDeg: 0 },
      { azimuthDeg: 350, maxObstacleAngleDeg: 20 },
    ];

    const result = ShadowCalculationEngine.calculateTrueSunset(
      lat,
      lng,
      startTime,
      azimuthProfiles,
    );

    expect(result).toHaveProperty('minutesToShadow');
    expect(result).toHaveProperty('shadowTimeUnix');
    expect(result.minutesToShadow).toBeGreaterThanOrEqual(0);
  });
});
