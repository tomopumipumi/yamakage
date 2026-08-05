import { OpenAPIHono } from '@hono/zod-openapi';
import type { Logger } from '../../application/interfaces/Logger';
import { createCalculateShadowUseCase } from '../../application/usecases/CalculateShadowUseCase';
import { createTileElevationRepository } from '../../infrastructure/repositories/TileElevationRepository';
import type { Bindings } from '../../types/env';
import { createTurnstileAuthMiddleware } from '../middlewares/turnstileAuth';
import { WebShadowRequestSchema, WebShadowResponseSchema } from '../schemas/webShadow';

export const postWebShadowRoute = {
  method: 'post' as const,
  path: '/',
  request: {
    body: {
      content: { 'application/json': { schema: WebShadowRequestSchema } },
    },
  },
  security: [{ TurnstileAuth: [] }],
  responses: {
    200: {
      content: { 'application/json': { schema: WebShadowResponseSchema } },
      description: 'Returns the true sunset and sunrise times.',
    },
    400: { description: 'Invalid parameters' },
    401: { description: 'Unauthorized: Missing Turnstile token' },
    403: { description: 'Forbidden: Invalid Turnstile token' },
    429: { description: 'Rate limit exceeded' },
    500: { description: 'Internal Server Error' },
  },
};

export const createWebShadowRouter = (logger: Logger) => {
  const router = new OpenAPIHono<{ Bindings: Bindings }>();

  router.use('*', createTurnstileAuthMiddleware(logger));

  router.openapi(postWebShadowRoute, async (c) => {
    const { lat, lng, time } = c.req.valid('json');

    const targetTime = time ? new Date(time < 10000000000 ? time * 1000 : time) : new Date();

    const runInBackground = (promise: Promise<void>) => {
      c.executionCtx.waitUntil(promise);
    };

    const elevationRepo = createTileElevationRepository(
      c.env.yamakage_terrain_tiles,
      runInBackground,
      logger,
    );

    const calcExecuterAsync = createCalculateShadowUseCase({
      elevationRepository: elevationRepo,
      logger,
    });

    const result = await calcExecuterAsync(lat, lng, targetTime);

    if (result.isPolar || !result.sunsetResult || !result.sunriseResult) {
      return c.json(
        {
          sunsetTime: null,
          minutesToSunset: null,
          sunriseTime: null,
          minutesToSunrise: null,
          isPolar: true,
        },
        200,
      );
    }

    return c.json(
      {
        sunsetTime: result.sunsetResult.shadowTimeUnix,
        minutesToSunset: result.sunsetResult.minutesToShadow,
        sunriseTime: result.sunriseResult.sunriseTimeUnix,
        minutesToSunrise: result.sunriseResult.minutesToSunrise,
        isPolar: false,
      },
      200,
    );
  });

  return router;
};
