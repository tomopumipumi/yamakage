import { OpenAPIHono } from '@hono/zod-openapi';
import { Effect, Exit } from 'effect';
import { ElevationRepositoryService } from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import { calculateShadow } from '../../application/usecases/CalculateShadowUseCase';
import { createTileElevationRepository } from '../../infrastructure/repositories/TileElevationRepository';
import type { Bindings } from '../../types/env';
import { createAuthMiddleware } from '../middlewares/auth';
import {
  WatchAppShadowRequestSchema,
  WatchAppShadowResponseSchema,
} from '../schemas/watchAppShadow';

export const postAppShadowRoute = {
  method: 'post' as const,
  path: '/',
  request: {
    body: {
      content: { 'application/json': { schema: WatchAppShadowRequestSchema } },
    },
  },
  security: [{ BearerAuth: [] }],
  responses: {
    200: {
      content: { 'application/json': { schema: WatchAppShadowResponseSchema } },
      description: 'Returns memory-optimized shadow data.',
    },
    400: { description: 'Invalid parameters' },
    401: { description: 'Unauthorized' },
    429: { description: 'Rate limit exceeded' },
    500: { description: 'Internal Server Error' },
  },
};

export const createWatchAppShadowRouter = (logger: Logger) => {
  const router = new OpenAPIHono<{ Bindings: Bindings }>();

  router.use('*', createAuthMiddleware(logger));

  router.openapi(postAppShadowRoute, async (c) => {
    const { lat, lng, time } = c.req.valid('json');
    const targetTime = time ? new Date(time < 10000000000 ? time * 1000 : time) : new Date();

    const runInBackground = (promise: Promise<void>) => c.executionCtx.waitUntil(promise);
    const elevationRepo = createTileElevationRepository(
      c.env.yamakage_terrain_tiles,
      runInBackground,
    );

    const STEP_DEG = 3;
    const program = calculateShadow({ lat, lng, targetTime, stepDeg: STEP_DEG, quality: 2 }).pipe(
      Effect.provideService(ElevationRepositoryService, elevationRepo),
      Effect.provideService(LoggerService, logger),
    );

    const exit = await Effect.runPromiseExit(program);

    if (Exit.isSuccess(exit)) {
      const result = exit.value;

      const azimuthProfilesFlat = result.azimuthProfiles.map((p) => [
        p.maxObstacleAngleDeg ?? 0,
        p.distance ?? 0,
      ]);

      const sunPathsFlat = result.sunPath.map((sp) => [sp.time, sp.azimuth, sp.altitude]);

      const sunsetUnix = result.sunsetResult?.shadowTimeUnix ?? -1;
      const sunriseUnix = result.sunriseResult?.sunriseTimeUnix ?? -1;

      return c.json(
        {
          d: [
            sunsetUnix,
            sunriseUnix,
            result.currentAltitude,
            STEP_DEG,
            azimuthProfilesFlat,
            sunPathsFlat,
          ],
        },
        200,
      );
    } else {
      logger.error('App shadow calculation failed', exit.cause);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  });

  return router;
};
