import { describe, expect, it } from 'vitest';
import { getObstacleType } from './obstacleUtils';

describe('getObstacleType', () => {
  it('returns horizon when target point is missing', () => {
    expect(getObstacleType(undefined, 10)).toBe('horizon');
  });

  describe('when elevation data (highestAltitude) is present', () => {
    it('returns horizon when the highest point is at or below 0m above sea level', () => {
      const pt = { azimuth: 0, terrain: 10, highestAltitude: 0 };
      expect(getObstacleType(pt, 100)).toBe('horizon');
    });

    it('returns small when the elevation difference from the current location is 100m or less (including looking down)', () => {
      const pt = { azimuth: 0, terrain: 10, highestAltitude: 150 };
      expect(getObstacleType(pt, 100)).toBe('small');
      const ptLower = { azimuth: 0, terrain: -5, highestAltitude: 50 };
      expect(getObstacleType(ptLower, 100)).toBe('small');
    });

    it('returns mountain when the elevation difference from the current location exceeds 100m', () => {
      const pt = { azimuth: 0, terrain: 10, highestAltitude: 300 };
      expect(getObstacleType(pt, 100)).toBe('mountain');
    });
  });

  describe('when elevation data is absent (fallback)', () => {
    it('returns horizon when the elevation angle is 0 degrees or less', () => {
      const pt = { azimuth: 0, terrain: 0 };
      expect(getObstacleType(pt, null)).toBe('horizon');
    });

    it('returns small when the elevation angle is greater than 0 degrees and up to 3 degrees', () => {
      const pt = { azimuth: 0, terrain: 2.5 };
      expect(getObstacleType(pt, null)).toBe('small');
    });

    it('returns mountain when the elevation angle exceeds 3 degrees', () => {
      const pt = { azimuth: 0, terrain: 5.0 };
      expect(getObstacleType(pt, null)).toBe('mountain');
    });
  });
});
