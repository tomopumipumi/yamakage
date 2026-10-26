import { OpenAPIHono } from '@hono/zod-openapi';
import { Effect, Exit } from 'effect';
import { ElevationRepositoryService } from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import { calculateMoonShadow } from '../../application/usecases/CalculateMoonShadowUseCase';
import { calculateShadow } from '../../application/usecases/CalculateShadowUseCase';
import { createTileElevationRepository } from '../../infrastructure/repositories/TileElevationRepository';
import type { Bindings } from '../../types/env';
import { createAuthMiddleware } from '../middlewares/auth';
import { ComplicationRequestSchema, ComplicationResponseSchema } from '../schemas/complication';

export const postComplicationRoute = {
  method: 'post' as const,
  path: '/',
  request: {
    body: {
      content: { 'application/json': { schema: ComplicationRequestSchema } },
    },
  },
  security: [{ BearerAuth: [] }],
  responses: {
    200: {
      content: { 'application/json': { schema: ComplicationResponseSchema } },
      description: 'Returns memory-optimized scalar data for Complications.',
    },
    400: { description: 'Invalid parameters' },
    401: { description: 'Unauthorized' },
    429: { description: 'Rate limit exceeded' },
    500: { description: 'Internal Server Error' },
  },
};

export const createComplicationRouter = (logger: Logger) => {
  const router = new OpenAPIHono<{ Bindings: Bindings }>();

  router.use('*', createAuthMiddleware(logger));

  router.openapi(postComplicationRoute, async (c) => {
    const { lat, lng, time } = c.req.valid('json');
    const targetTime = time ? new Date(time < 10000000000 ? time * 1000 : time) : new Date();

    const runInBackground = (promise: Promise<void>) => c.executionCtx.waitUntil(promise);
    const elevationRepo = createTileElevationRepository(
      c.env.yamakage_terrain_tiles,
      runInBackground,
    );

    const STEP_DEG = 3;

    const sunProgram = calculateShadow({ lat, lng, targetTime, stepDeg: STEP_DEG, quality: 2 });
    const moonProgram = calculateMoonShadow({
      lat,
      lng,
      targetTime,
      stepDeg: STEP_DEG,
      quality: 2,
    });

    const program = Effect.all([sunProgram, moonProgram]).pipe(
      Effect.provideService(ElevationRepositoryService, elevationRepo),
      Effect.provideService(LoggerService, logger),
    );

    const exit = await Effect.runPromiseExit(program);

    if (Exit.isSuccess(exit)) {
      const [sunResult, moonResult] = exit.value;

      const payload = [
        sunResult.sunriseResult?.sunriseTimeUnix ?? null,
        sunResult.sunsetResult?.shadowTimeUnix ?? null,
        moonResult.moonriseResult?.sunriseTimeUnix ?? null,
        moonResult.moonsetResult?.shadowTimeUnix ?? null,
        moonResult.phase,
        moonResult.fraction,
        sunResult.currentAltitude,
      ];

      return c.json({ d: payload }, 200);
    } else {
      logger.error('Complication calculation failed', exit.cause);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  });

  return router;
};
