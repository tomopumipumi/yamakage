import { Effect, Option } from 'effect';
import { ElevationFetchError } from '../../application/errors';
import type {
  ElevationRepository,
  TileFetchResult,
} from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import type { Coordinate } from '../../application/types/calculator';
import { getTileCoordinates, ZOOM_LEVEL } from '../../utils/tileMath';
import { fetchTileFromAWS } from '../clients/AwsTerrainClient';

const memoryCache = new Map<string, ArrayBuffer>();

interface TileRequest {
  z: number;
  x: number;
  y: number;
  points: { index: number; px: number; py: number }[];
}

const getTileKey = (lat: number, lng: number, zoom: number) => {
  const { tileX, tileY, pixelX, pixelY } = getTileCoordinates(lat, lng, zoom);
  return { tileX, tileY, pixelX, pixelY, tileKey: `${zoom}/${tileX}/${tileY}` };
};

const groupPointsByTile = (points: Coordinate[]): Map<string, TileRequest> => {
  const tileMap = new Map<string, TileRequest>();

  for (let index = 0; index < points.length; index++) {
    const p = points[index];
    const { tileX, tileY, pixelX, pixelY, tileKey } = getTileKey(p.lat, p.lng, ZOOM_LEVEL);

    let req = tileMap.get(tileKey);
    if (!req) {
      req = { z: ZOOM_LEVEL, x: tileX, y: tileY, points: [] };
      tileMap.set(tileKey, req);
    }

    req.points.push({ index, px: pixelX, py: pixelY });
  }

  return tileMap;
};

const fetchFromR2 = (bucket: R2Bucket, tilePath: string) =>
  Effect.gen(function* (_) {
    if (memoryCache.has(tilePath)) return Option.some(memoryCache.get(tilePath));

    const logger = yield* _(LoggerService);
    return yield* _(
      Effect.tryPromise({
        try: async () => {
          const r2Obj = await bucket.get(tilePath);
          if (r2Obj) {
            const buffer = await r2Obj.arrayBuffer();
            memoryCache.set(tilePath, buffer);
            return buffer;
          }
          return null;
        },
        catch: (e) => new ElevationFetchError('R2 fetch failed', e),
      }).pipe(
        Effect.map(Option.fromNullable),
        Effect.catchAll((e) => {
          logger.warn(`Failed to fetch tile ${tilePath} from R2`, { error: e });
          return Effect.succeed(Option.none());
        }),
      ),
    );
  });

const fetchFromAWSAndCache = (
  tileReq: TileRequest,
  tilePath: string,
  bucket: R2Bucket,
  runInBackground: (promise: Promise<void>) => void,
) =>
  Effect.gen(function* (_) {
    const logger = yield* _(LoggerService);
    const awsData = yield* _(
      fetchTileFromAWS(tileReq.z, tileReq.x, tileReq.y).pipe(
        Effect.map(Option.fromNullable),
        Effect.catchAll((e) => {
          logger.error(`Error fetching tile ${tilePath} from AWS`, e);
          return Effect.succeed(Option.none());
        }),
      ),
    );

    if (Option.isSome(awsData)) {
      const bufferForR2 = awsData.value;
      runInBackground(
        (async () => {
          try {
            await bucket.put(tilePath, bufferForR2, { httpMetadata: { contentType: 'image/png' } });
          } catch (e) {
            logger.error(`Failed to save tile ${tilePath} to R2`, e);
          }
        })(),
      );
    }

    return awsData;
  });

export const createTileElevationRepository = (
  bucket: R2Bucket,
  runInBackground: (promise: Promise<void>) => void,
): ElevationRepository => {
  return {
    fetchTileData: (
      points: Coordinate[],
    ): Effect.Effect<TileFetchResult[], ElevationFetchError, Logger> =>
      Effect.gen(function* (_) {
        const logger = yield* _(LoggerService);
        const tileMap = groupPointsByTile(points);

        logger.debug('Mapped points to tiles', {
          tileCount: tileMap.size,
          totalPoints: points.length,
        });

        const processSingleTile = (
          tileReq: TileRequest,
        ): Effect.Effect<TileFetchResult, ElevationFetchError, Logger> =>
          Effect.gen(function* (_) {
            const tilePath = `${tileReq.z}/${tileReq.x}/${tileReq.y}.png`;

            let imgDataOpt = yield* _(fetchFromR2(bucket, tilePath));

            if (Option.isNone(imgDataOpt)) {
              imgDataOpt = yield* _(
                fetchFromAWSAndCache(tileReq, tilePath, bucket, runInBackground),
              );
            }

            const buffer = Option.getOrNull(imgDataOpt);

            return {
              buffer: buffer !== undefined ? buffer : null,
              points: tileReq.points,
            };
          });

        return yield* _(
          Effect.all(Array.from(tileMap.values()).map(processSingleTile), {
            concurrency: 'unbounded',
          }),
        );
      }),
  };
};
