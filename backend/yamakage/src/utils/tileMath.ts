export const ZOOM_LEVEL = 12;
export const TILE_SIZE = 256;

export function getTileCoordinates(lat: number, lng: number, zoom: number) {
  const latRad = (lat * Math.PI) / 180;
  const n = 2 ** zoom;
  const x = ((lng + 180) / 360) * n;
  const y = ((1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI) / 2) * n;

  const tileX = Math.floor(x);
  const tileY = Math.floor(y);

  const pixelX = Math.floor((x - tileX) * TILE_SIZE);
  const pixelY = Math.floor((y - tileY) * TILE_SIZE);

  return { tileX, tileY, pixelX, pixelY };
}
