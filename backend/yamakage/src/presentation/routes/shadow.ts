import { OpenAPIHono } from '@hono/zod-openapi';
import { Effect, Exit } from 'effect';
import { ElevationRepositoryService } from '../../application/interfaces/ElevationRepository';
import { type Logger, LoggerService } from '../../application/interfaces/Logger';
import { calculateShadow } from '../../application/usecases/CalculateShadowUseCase';
import { createTileElevationRepository } from '../../infrastructure/repositories/TileElevationRepository';
import type { Bindings } from '../../types/env';
import { createAuthMiddleware } from '../middlewares/auth';
import { ShadowQuerySchema, ShadowResponseSchema } from '../schemas/shadow';

export const getShadowRoute = {
  method: 'get' as const,
  path: '/',
  request: { query: ShadowQuerySchema },
  security: [{ BearerAuth: [] }],
  responses: {
    200: {
      content: { 'application/json': { schema: ShadowResponseSchema } },
      description: 'Returns the remaining time until true sunset and sunrise.',
    },
    400: { description: 'Invalid parameters' },
    429: { description: 'External API rate limit reached' },
    502: { description: 'External API error (Bad Gateway)' },
  },
};

export const createShadowRouter = (logger: Logger) => {
  const router = new OpenAPIHono<{ Bindings: Bindings }>();

  router.use('*', createAuthMiddleware(logger));

  router.openapi(getShadowRoute, async (c) => {
    const { lat, lng, time } = c.req.valid('query');
    const targetTime = time ? new Date(time < 10000000000 ? time * 1000 : time) : new Date();

    const runInBackground = (promise: Promise<void>) => c.executionCtx.waitUntil(promise);
    const elevationRepo = createTileElevationRepository(
      c.env.yamakage_terrain_tiles,
      runInBackground,
    );

    const program = calculateShadow({ lat, lng, targetTime, stepDeg: 1, quality: 2 }).pipe(
      Effect.provideService(ElevationRepositoryService, elevationRepo),
      Effect.provideService(LoggerService, logger),
    );

    const exit = await Effect.runPromiseExit(program);

    if (Exit.isSuccess(exit)) {
      const result = exit.value;
      if (result.isPolar || !result.sunsetResult || !result.sunriseResult) {
        return c.json({ d: [0, 0, 0, 0] }, 200);
      }
      return c.json(
        {
          d: [
            result.sunsetResult.minutesToShadow,
            result.sunsetResult.shadowTimeUnix,
            result.sunriseResult.minutesToSunrise,
            result.sunriseResult.sunriseTimeUnix,
          ],
        },
        200,
      );
    } else {
      logger.error('Shadow calculation failed', exit.cause);
      return c.json({ error: 'Internal Server Error' }, 500);
    }
  });

  return router;
};
