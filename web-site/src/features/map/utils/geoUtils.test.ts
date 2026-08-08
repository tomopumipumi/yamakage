import { describe, expect, it } from 'vitest';
import { createSectorPoints, getDestinationPoint } from './geoUtils';

describe('geoUtils', () => {
  describe('getDestinationPoint', () => {
    it('when calculating distance heading north, latitude increases and longitude remains almost unchanged', () => {
      const lat = 35.0;
      const lng = 135.0;
      const dist = 10000; // 10km
      const brng = 0; // North (0 degrees)

      const dest = getDestinationPoint(lat, lng, brng, dist);

      expect(dest.lat).toBeGreaterThan(lat);
      expect(Math.abs(dest.lng - lng)).toBeLessThan(0.0001);
    });

    it('when calculating distance heading east, longitude increases', () => {
      const lat = 35.0;
      const lng = 135.0;
      const dist = 10000; // 10km
      const brng = 90; // East (90 degrees)

      const dest = getDestinationPoint(lat, lng, brng, dist);

      expect(dest.lng).toBeGreaterThan(lng);
    });
  });

  describe('createSectorPoints', () => {
    it('generates the specified number of steps + 1 points, including the center point', () => {
      const points = createSectorPoints(35.0, 135.0, 90, 10000, 15, 10);

      expect(points.length).toBe(12);
      expect(points[0]).toEqual([35.0, 135.0]);
    });
  });
});