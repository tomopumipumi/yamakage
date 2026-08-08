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

  it('returns -1 for time when the sun never crosses the obstacle within 48 hours (polar day/night timeout)', () => {
    const lat = 80.0; // Polar region
    const lng = 0.0;
    const startTime = new Date('2024-12-21T12:00:00Z'); // Winter solstice (polar night)

    const azimuthProfiles: TerrainAzimuthProfile[] = [{ azimuthDeg: 180, maxObstacleAngleDeg: 10 }];

    const result = ShadowCalculationEngine.calculateTrueSunrise(
      lat,
      lng,
      startTime,
      azimuthProfiles,
    );

    expect(result.minutesToSunrise).toBe(0);
    expect(result.sunriseTimeUnix).toBe(-1);
  });

  it('handles empty azimuthProfiles array correctly by using the default horizon angle', () => {
    const lat = 34.81;
    const lng = 135.534;
    const startTime = new Date('2024-06-10T04:00:00Z');

    const result = ShadowCalculationEngine.calculateTrueSunset(lat, lng, startTime, []);

    expect(result.minutesToShadow).toBeGreaterThan(0);
    expect(result.shadowTimeUnix).toBeGreaterThan(0);
  });

  it('handles azimuthProfiles array with only one element correctly', () => {
    const lat = 34.81;
    const lng = 135.534;
    const startTime = new Date('2024-06-10T04:00:00Z');

    const result = ShadowCalculationEngine.calculateTrueSunset(lat, lng, startTime, [
      { azimuthDeg: 100, maxObstacleAngleDeg: 10 },
    ]);

    expect(result.minutesToShadow).toBeGreaterThan(0);
    expect(result.shadowTimeUnix).toBeGreaterThan(0);
  });

  it('finds the next sunset even if it is already night time at the start', () => {
    const lat = 34.81;
    const lng = 135.534;
    const startTime = new Date('2024-06-10T15:00:00Z'); // 15:00 UTC is midnight in Japan Standard Time

    const azimuthProfiles: TerrainAzimuthProfile[] = [{ azimuthDeg: 270, maxObstacleAngleDeg: 5 }];

    const result = ShadowCalculationEngine.calculateTrueSunset(
      lat,
      lng,
      startTime,
      azimuthProfiles,
    );

    expect(result.minutesToShadow).toBeGreaterThan(600);
    expect(result.shadowTimeUnix).toBeGreaterThan(0);
  });
});
