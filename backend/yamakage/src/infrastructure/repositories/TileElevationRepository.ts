import { Effect, Option } from 'effect';
import { decode } from 'fast-png';
import { ElevationFetchError } from '../../application/errors';
import type { ElevationRepository } from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import type { Coordinate } from '../../application/types/calculator';
import { getTileCoordinates, ZOOM_LEVEL } from '../../utils/tileMath';
import { fetchTileFromAWS } from '../clients/AwsTerrainClient';

interface TileRequest {
  z: number;
  x: number;
  y: number;
  points: { key: string; px: number; py: number }[];
}

const getIntCoordinate = (coord: number) => Math.round(coord * 1000000);

const groupPointsByTile = (points: Coordinate[]): Map<string, TileRequest> => {
  return points.reduce((acc, p) => {
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
};

const fetchFromR2 = (bucket: R2Bucket, tilePath: string) =>
  Effect.gen(function* (_) {
    const logger = yield* _(LoggerService);
    return yield* _(
      Effect.tryPromise({
        try: async () => {
          const r2Obj = await bucket.get(tilePath);
          return r2Obj ? await r2Obj.arrayBuffer() : null;
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
      const bufferForR2 = awsData.value.slice(0);
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

const decodeElevationData = (
  imgData: ArrayBuffer,
  points: TileRequest['points'],
  tilePath: string,
) =>
  Effect.gen(function* (_) {
    const logger = yield* _(LoggerService);
    return yield* _(
      Effect.try({
        try: () => {
          const png = decode(new Uint8Array(imgData));
          const { width, data, channels } = png;

          return points.map((p): [string, number] => {
            const idx = (p.py * width + p.px) * channels;
            const r = data[idx];
            const g = data[idx + 1];
            const b = data[idx + 2];
            const elevation = r * 256 + g + b / 256 - 32768;
            return [p.key, Math.max(0, Math.round(elevation))];
          });
        },
        catch: (e) => new ElevationFetchError('PNG Decode Error', e),
      }).pipe(
        Effect.catchAll((e) => {
          logger.error(`Failed to decode PNG for tile ${tilePath}`, e);
          return Effect.succeed(points.map((p): [string, number] => [p.key, 0]));
        }),
      ),
    );
  });

export const createTileElevationRepository = (
  bucket: R2Bucket,
  runInBackground: (promise: Promise<void>) => void,
): ElevationRepository => {
  return {
    getElevations: (
      points: Coordinate[],
    ): Effect.Effect<Map<string, number>, ElevationFetchError, Logger> =>
      Effect.gen(function* (_) {
        const logger = yield* _(LoggerService);
        const tileMap = groupPointsByTile(points);

        logger.debug('Mapped points to tiles', {
          tileCount: tileMap.size,
          totalPoints: points.length,
        });

        const processSingleTile = (tileReq: TileRequest) =>
          Effect.gen(function* (_) {
            const tilePath = `${tileReq.z}/${tileReq.x}/${tileReq.y}.png`;

            let imgDataOpt = yield* _(fetchFromR2(bucket, tilePath));

            if (Option.isNone(imgDataOpt)) {
              imgDataOpt = yield* _(
                fetchFromAWSAndCache(tileReq, tilePath, bucket, runInBackground),
              );
            }

            if (Option.isSome(imgDataOpt)) {
              return yield* _(decodeElevationData(imgDataOpt.value, tileReq.points, tilePath));
            } else {
              return tileReq.points.map((p): [string, number] => [p.key, 0]);
            }
          });

        const resolvedTiles = yield* _(
          Effect.all(Array.from(tileMap.values()).map(processSingleTile), {
            concurrency: 'unbounded',
          }),
        );

        return new Map(resolvedTiles.flat());
      }),
  };
};
