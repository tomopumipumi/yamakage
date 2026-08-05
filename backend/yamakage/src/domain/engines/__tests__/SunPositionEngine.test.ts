import { describe, expect, it } from 'vitest';
import { SunPositionEngine } from '../SunPositionEngine';

describe('SunPositionEngine', () => {
  it('correctly calculates the sun position (altitude and azimuth) for a specified date, time, and coordinates', () => {
    const targetDate = new Date('2024-06-10T03:00:00Z');
    const lat = 34.81;
    const lng = 135.534;

    const result = SunPositionEngine.getPosition(targetDate, lat, lng);

    expect(result).toHaveProperty('altitudeRad');
    expect(result).toHaveProperty('azimuthRad');
    expect(result).toHaveProperty('altitudeDeg');
    expect(result).toHaveProperty('azimuthDeg');

    expect(result.altitudeDeg).toBeGreaterThan(0);
    expect(result.azimuthDeg).toBeGreaterThanOrEqual(0);
    expect(result.azimuthDeg).toBeLessThanOrEqual(360);
  });
});
