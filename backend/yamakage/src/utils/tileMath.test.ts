import { describe, expect, it } from 'vitest';
import { getTileCoordinates, ZOOM_LEVEL } from './tileMath';

describe('tileMath', () => {
  it('should calculate correct tile and pixel coordinates', () => {
    const lat = 35.3606;
    const lng = 138.7274;
    const zoom = ZOOM_LEVEL;

    const { tileX, tileY, pixelX, pixelY } = getTileCoordinates(lat, lng, zoom);

    expect(tileX).toBeGreaterThan(0);
    expect(tileY).toBeGreaterThan(0);

    expect(pixelX).toBeGreaterThanOrEqual(0);
    expect(pixelX).toBeLessThan(256);
    expect(pixelY).toBeGreaterThanOrEqual(0);
    expect(pixelY).toBeLessThan(256);
  });
});
