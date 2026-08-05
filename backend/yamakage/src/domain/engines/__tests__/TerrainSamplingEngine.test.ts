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
      expect(pane.points.length).toBe(16);

      pane.points.forEach((p) => {
        expect(p).toHaveProperty('lat');
        expect(p).toHaveProperty('lng');
        expect(p).toHaveProperty('distance');
        expect(p.distance).toBeGreaterThan(0);
      });
    });
  });
});
