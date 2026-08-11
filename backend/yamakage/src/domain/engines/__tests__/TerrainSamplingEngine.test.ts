import { describe, expect, it } from 'vitest';
import { TerrainSamplingEngine } from '../TerrainSamplingEngine';

describe('TerrainSamplingEngine', () => {
  it('correctly generates 360-degree panoramic sampling points', () => {
    const lat = 34.81;
    const lng = 135.534;
    const stepDeg = 15;

    const panorama = TerrainSamplingEngine.generateFullPanorama(lat, lng, stepDeg);

    expect(panorama.length).toBe(24);

    expect(panorama[0].azimuth).toBe(0);
    expect(panorama[23].azimuth).toBe(345);

    panorama.forEach((pane) => {
      expect(pane.points.length).toBeGreaterThan(0);
      expect(pane.points.length).toBe(145);

      pane.points.forEach((p) => {
        expect(p).toHaveProperty('lat');
        expect(p).toHaveProperty('lng');
        expect(p).toHaveProperty('distance');
        expect(p.distance).toBeGreaterThan(0);
      });
    });
  });

  it('calculates coordinates in the correct direction (e.g., heading true north only increases latitude)', () => {
    const lat = 34.0;
    const lng = 135.0;
    const stepDeg = 90; // Generates N(0), E(90), S(180), W(270)

    const panorama = TerrainSamplingEngine.generateFullPanorama(lat, lng, stepDeg);

    // Azimuth 0 (True North): Latitude increases, longitude remains almost unchanged
    const northPoints = panorama.find((p) => p.azimuth === 0)?.points;
    if (northPoints === undefined) throw new Error("'northPoints' is undefined.");
    expect(northPoints).toBeDefined();
    expect(northPoints[0].lat).toBeGreaterThan(lat);
    expect(Math.abs(northPoints[0].lng - lng)).toBeLessThan(0.0001); // Floating-point tolerance

    // Azimuth 180 (True South): Latitude decreases
    const southPoints = panorama.find((p) => p.azimuth === 180)?.points;
    if (southPoints === undefined) throw new Error("'southPoints' is undefined.");
    expect(southPoints).toBeDefined();
    expect(southPoints[0].lat).toBeLessThan(lat);

    // Azimuth 90 (True East): Longitude increases
    const eastPoints = panorama.find((p) => p.azimuth === 90)?.points;
    if (eastPoints === undefined) throw new Error("'eastPoints' is undefined.");
    expect(eastPoints).toBeDefined();
    expect(eastPoints[0].lng).toBeGreaterThan(lng);
  });

  it('changes distance intervals correctly according to the specified distance ranges', () => {
    const lat = 34.81;
    const lng = 135.534;

    const panorama = TerrainSamplingEngine.generateFullPanorama(lat, lng, 360); // Generates 0 degrees only
    const points = panorama[0].points;

    expect(points.length).toBe(145);

    // 0-1km: 30m intervals starting from 10m (34 points)
    expect(points[0].distance).toBe(10);
    expect(points[33].distance).toBe(1000);

    // 1km-5km: 100m intervals (40 points)
    expect(points[34].distance).toBe(1100);
    expect(points[73].distance).toBe(5000);

    // 5km-15km: 250m intervals (40 points)
    expect(points[74].distance).toBe(5100);
    expect(points[113].distance).toBe(14850);

    // 15km-30km: 500m intervals (31 points)
    expect(points[114].distance).toBe(15000);
    expect(points[144].distance).toBe(30000);
  });
});
