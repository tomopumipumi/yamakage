import { OpenAPIHono } from '@hono/zod-openapi';
import { Effect, Exit } from 'effect';
import { ElevationRepositoryService } from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import { calculateMoonShadow } from '../../application/usecases/CalculateMoonShadowUseCase';
import { createTileElevationRepository } from '../../infrastructure/repositories/TileElevationRepository';
import type { Bindings } from '../../types/env';
import { createTurnstileAuthMiddleware } from '../middlewares/turnstileAuth';
import { WebMoonShadowRequestSchema, WebMoonShadowResponseSchema } from '../schemas/webMoonShadow';

export const postWebMoonShadowRoute = {
  method: 'post' as const,
  path: '/',
  request: {
    body: {
      content: { 'application/json': { schema: WebMoonShadowRequestSchema } },
    },
  },
  security: [{ TurnstileAuth: [] }],
  responses: {
    200: {
      content: { 'application/json': { schema: WebMoonShadowResponseSchema } },
      description: 'Returns the true moonset and moonrise times.',
    },
    400: { description: 'Invalid parameters' },
    401: { description: 'Unauthorized: Missing Turnstile token' },
    403: { description: 'Forbidden: Invalid Turnstile token' },
    429: { description: 'Rate limit exceeded' },
    500: { description: 'Internal Server Error' },
  },
};

export const createWebMoonShadowRouter = (logger: Logger) => {
  const router = new OpenAPIHono<{ Bindings: Bindings }>();
  router.use('*', createTurnstileAuthMiddleware(logger));

  router.openapi(postWebMoonShadowRoute, async (c) => {
    const { lat, lng, time } = c.req.valid('json');
    const targetTime = time ? new Date(time < 10000000000 ? time * 1000 : time) : new Date();

    const runInBackground = (promise: Promise<void>) => c.executionCtx.waitUntil(promise);
    const elevationRepo = createTileElevationRepository(
      c.env.yamakage_terrain_tiles,
      runInBackground,
    );

    const program = calculateMoonShadow({ lat, lng, targetTime, stepDeg: 3, quality: 2 }).pipe(
      Effect.provideService(ElevationRepositoryService, elevationRepo),
      Effect.provideService(LoggerService, logger),
    );

    const exit = await Effect.runPromiseExit(program);

    if (Exit.isSuccess(exit)) {
      const result = exit.value;
      if (result.isPolar || !result.moonsetResult || !result.moonriseResult) {
        return c.json(
          {
            moonsetTime: null,
            minutesToMoonset: null,
            moonriseTime: null,
            minutesToMoonrise: null,
            isPolar: true,
            fraction: result.fraction,
            phase: result.phase,
            currentAltitude: result.currentAltitude,
          },
          200,
        );
      }
      return c.json(
        {
          moonsetTime: result.moonsetResult.shadowTimeUnix,
          minutesToMoonset: result.moonsetResult.minutesToShadow,
          moonriseTime: result.moonriseResult.sunriseTimeUnix,
          minutesToMoonrise: result.moonriseResult.minutesToSunrise,
          isPolar: false,
          fraction: result.fraction,
          phase: result.phase,
          azimuthProfiles: result.azimuthProfiles,
          moonPath: result.moonPath,
          currentAltitude: result.currentAltitude,
        },
        200,
      );
    } else {
      logger.error('Web moon shadow calculation failed', exit.cause);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  });

  return router;
};
