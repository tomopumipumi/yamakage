import { decode } from 'fast-png';
import type { Logger } from '../../application/interfaces/Logger';
import type { Coordinate } from '../../domain/models/types';
import type { ElevationRepository } from '../../domain/repositories/ElevationRepository';
import { getTileCoordinates, ZOOM_LEVEL } from '../../utils/tileMath';
import { fetchTileFromAWS } from '../clients/AwsTerrainClient';

export const createTileElevationRepository = (
  bucket: R2Bucket,
  runInBackground: (promise: Promise<void>) => void,
  logger: Logger,
): ElevationRepository => {
  const getIntCoordinate = (coord: number) => Math.round(coord * 1000);

  return {
    getElevations: async (points: Coordinate[]): Promise<Map<string, number>> => {
      const tileMap = new Map<
        string,
        { z: number; x: number; y: number; points: { key: string; px: number; py: number }[] }
      >();

      for (const p of points) {
        const key = `${getIntCoordinate(p.lat)}_${getIntCoordinate(p.lng)}`;
        const { tileX, tileY, pixelX, pixelY } = getTileCoordinates(p.lat, p.lng, ZOOM_LEVEL);
        const tileKey = `${ZOOM_LEVEL}/${tileX}/${tileY}`;

        let tileData = tileMap.get(tileKey);
        if (!tileData) {
          tileData = { z: ZOOM_LEVEL, x: tileX, y: tileY, points: [] };
          tileMap.set(tileKey, tileData);
        }
        tileData.points.push({ key, px: pixelX, py: pixelY });
      }

      logger.debug('Mapped points to tiles', {
        tileCount: tileMap.size,
        totalPoints: points.length,
      });

      const results = new Map<string, number>();

      const tilePromises = Array.from(tileMap.values()).map(async (tileReq) => {
        const tilePath = `${tileReq.z}/${tileReq.x}/${tileReq.y}.png`;
        let imgData: ArrayBuffer | null = null;

        try {
          const r2Obj = await bucket.get(tilePath);
          if (r2Obj) {
            imgData = await r2Obj.arrayBuffer();
          }
        } catch (e) {
          logger.warn(`Failed to fetch tile ${tilePath} from R2`, { error: e });
        }

        if (!imgData) {
          try {
            imgData = await fetchTileFromAWS(tileReq.z, tileReq.x, tileReq.y);
            if (imgData) {
              const bufferForR2 = imgData.slice(0);

              runInBackground(
                (async () => {
                  try {
                    await bucket.put(tilePath, bufferForR2, {
                      httpMetadata: { contentType: 'image/png' },
                    });
                  } catch (e) {
                    logger.error(`Failed to save tile ${tilePath} to R2`, e);
                  }
                })(),
              );
            }
          } catch (e) {
            logger.error(`Error fetching tile ${tilePath} from S3`, e);
          }
        }

        if (imgData) {
          try {
            const png = decode(new Uint8Array(imgData));
            const { width, data, channels } = png;

            for (const p of tileReq.points) {
              const idx = (p.py * width + p.px) * channels;
              const r = data[idx];
              const g = data[idx + 1];
              const b = data[idx + 2];
              const elevation = r * 256 + g + b / 256 - 32768;
              results.set(p.key, Math.round(elevation));
            }
          } catch (e) {
            logger.error(`Failed to decode PNG for tile ${tilePath}`, e);
            for (const p of tileReq.points) {
              results.set(p.key, 0);
            }
          }
        } else {
          for (const p of tileReq.points) {
            results.set(p.key, 0);
          }
        }
      });

      await Promise.all(tilePromises);
      return results;
    },
  };
};
