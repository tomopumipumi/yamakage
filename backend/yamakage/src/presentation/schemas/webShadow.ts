import { z } from '@hono/zod-openapi';

export const WebShadowRequestSchema = z.object({
  lat: z.coerce.number().min(-90).max(90).openapi({ example: 34.81 }),
  lng: z.coerce.number().min(-180).max(180).openapi({ example: 135.534 }),
  time: z.coerce.number().optional().openapi({ example: 1718000000000 }),
});

export const WebShadowResponseSchema = z.object({
  sunsetTime: z.number().nullable().describe('Unix timestamp of true sunset. Null if polar day/night.'),
  minutesToSunset: z.number().nullable(),
  sunriseTime: z.number().nullable(),
  minutesToSunrise: z.number().nullable(),
  isPolar: z.boolean().describe('True if polar day or night applies'),
}).openapi({
  description: 'Rich JSON format for web clients',
  example: {
    sunsetTime: 1718000000,
    minutesToSunset: 45,
    sunriseTime: 1718040000,
    minutesToSunrise: 30,
    isPolar: false
  }
});