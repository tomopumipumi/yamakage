import { OpenAPIHono } from '@hono/zod-openapi';
import { Effect, Exit } from 'effect';
import { ElevationRepositoryService } from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import { calculateMoonShadow } from '../../application/usecases/CalculateMoonShadowUseCase';
import { createTileElevationRepository } from '../../infrastructure/repositories/TileElevationRepository';
import type { Bindings } from '../../types/env';
import { createAuthMiddleware } from '../middlewares/auth';
import {
  WatchAppMoonShadowRequestSchema,
  WatchAppMoonShadowResponseSchema,
} from '../schemas/watchAppMoonShadow';

export const postAppMoonShadowRoute = {
  method: 'post' as const,
  path: '/',
  request: {
    body: {
      content: { 'application/json': { schema: WatchAppMoonShadowRequestSchema } },
    },
  },
  security: [{ BearerAuth: [] }],
  responses: {
    200: {
      content: { 'application/json': { schema: WatchAppMoonShadowResponseSchema } },
      description: 'Returns memory-optimized moon shadow data.',
    },
    400: { description: 'Invalid parameters' },
    401: { description: 'Unauthorized' },
    429: { description: 'Rate limit exceeded' },
    500: { description: 'Internal Server Error' },
  },
};

export const createWatchAppMoonShadowRouter = (logger: Logger) => {
  const router = new OpenAPIHono<{ Bindings: Bindings }>();

  router.use('*', createAuthMiddleware(logger));

  router.openapi(postAppMoonShadowRoute, async (c) => {
    const { lat, lng, time } = c.req.valid('json');
    const targetTime = time ? new Date(time < 10000000000 ? time * 1000 : time) : new Date();

    const runInBackground = (promise: Promise<void>) => c.executionCtx.waitUntil(promise);
    const elevationRepo = createTileElevationRepository(
      c.env.yamakage_terrain_tiles,
      runInBackground,
    );

    const STEP_DEG = 3;
    const program = calculateMoonShadow({
      lat,
      lng,
      targetTime,
      stepDeg: STEP_DEG,
      quality: 2,
    }).pipe(
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

      const moonPathsFlat = result.moonPath.map((sp) => [sp.time, sp.azimuth, sp.altitude]);

      const moonsetUnix = result.moonsetResult?.shadowTimeUnix ?? -1;
      const moonriseUnix = result.moonriseResult?.sunriseTimeUnix ?? -1;

      return c.json(
        {
          d: [
            moonsetUnix,
            moonriseUnix,
            result.currentAltitude,
            STEP_DEG,
            result.fraction,
            result.phase,
            azimuthProfilesFlat,
            moonPathsFlat,
          ],
        },
        200,
      );
    } else {
      logger.error('App moon shadow calculation failed', exit.cause);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  });

  return router;
};
