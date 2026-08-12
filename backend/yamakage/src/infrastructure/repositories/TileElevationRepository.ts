import { decode } from 'fast-png';
import type { Logger } from '../../application/interfaces/Logger';
import type { Coordinate } from '../../domain/models/types';
import type { ElevationRepository } from '../../domain/repositories/ElevationRepository';
import { getTileCoordinates, ZOOM_LEVEL } from '../../utils/tileMath';
import { fetchTileFromAWS } from '../clients/AwsTerrainClient';

interface TileRequest {
  z: number;
  x: number;
  y: number;
  points: { key: string; px: number; py: number }[];
}

export const createTileElevationRepository = (
  bucket: R2Bucket,
  runInBackground: (promise: Promise<void>) => void,
  logger: Logger,
): ElevationRepository => {
  const getIntCoordinate = (coord: number) => Math.round(coord * 100000);

  return {
    getElevations: async (points: Coordinate[]): Promise<Map<string, number>> => {
      const tileMap = points.reduce((acc, p) => {
        const key = `${getIntCoordinate(p.lat)}_${getIntCoordinate(p.lng)}`;
        const { tileX, tileY, pixelX, pixelY } = getTileCoordinates(p.lat, p.lng, ZOOM_LEVEL);
        const tileKey = `${ZOOM_LEVEL}/${tileX}/${tileY}`;

        const existing = acc.get(tileKey) ?? { z: ZOOM_LEVEL, x: tileX, y: tileY, points: [] };

        acc.set(tileKey, {
          ...existing,
          points: [...existing.points, { key, px: pixelX, py: pixelY }],
        });

        return acc;
      }, new Map<string, TileRequest>());

      logger.debug('Mapped points to tiles', {
        tileCount: tileMap.size,
        totalPoints: points.length,
      });

      const tilePromises = Array.from(tileMap.values()).map(async (tileReq) => {
        const tilePath = `${tileReq.z}/${tileReq.x}/${tileReq.y}.png`;

        const fetchImage = async (): Promise<ArrayBuffer | null> => {
          try {
            const r2Obj = await bucket.get(tilePath);
            if (r2Obj) return await r2Obj.arrayBuffer();
          } catch (e) {
            logger.warn(`Failed to fetch tile ${tilePath} from R2`, { error: e });
          }

          try {
            const awsData = await fetchTileFromAWS(tileReq.z, tileReq.x, tileReq.y);
            if (awsData) {
              const bufferForR2 = awsData.slice(0);
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
              return awsData;
            }
          } catch (e) {
            logger.error(`Error fetching tile ${tilePath} from S3`, e);
          }

          return null;
        };

        const imgData = await fetchImage();

        if (imgData) {
          try {
            const png = decode(new Uint8Array(imgData));
            const { width, data, channels } = png;

            return tileReq.points.map((p): [string, number] => {
              const idx = (p.py * width + p.px) * channels;
              const r = data[idx];
              const g = data[idx + 1];
              const b = data[idx + 2];
              const elevation = r * 256 + g + b / 256 - 32768;
              const adjustedElevation = Math.max(0, Math.round(elevation));
              return [p.key, adjustedElevation];
            });
          } catch (e) {
            logger.error(`Failed to decode PNG for tile ${tilePath}`, e);
            return tileReq.points.map((p): [string, number] => [p.key, 0]);
          }
        }

        return tileReq.points.map((p): [string, number] => [p.key, 0]);
      });

      const resolvedTiles = await Promise.all(tilePromises);
      return new Map(resolvedTiles.flat());
    },
  };
};
