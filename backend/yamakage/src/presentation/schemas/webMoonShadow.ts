import { z } from '@hono/zod-openapi';

export const WebMoonShadowRequestSchema = z.object({
  lat: z.coerce.number().min(-89.999).max(89.999).openapi({ example: 34.81 }),
  lng: z.coerce.number().min(-180).max(180).openapi({ example: 135.534 }),
  time: z.coerce.number().optional().openapi({ example: 1718000000000 }),
});

export const WebMoonShadowResponseSchema = z
  .object({
    moonsetTime: z
      .number()
      .nullable()
      .describe('Unix timestamp of true moonset. Null if polar day/night.'),
    minutesToMoonset: z.number().nullable(),
    moonriseTime: z.number().nullable(),
    minutesToMoonrise: z.number().nullable(),
    isPolar: z.boolean().describe('True if polar day or night applies'),
    fraction: z.number().describe('Moon illumination fraction (0.0 to 1.0)'),
    phase: z.number().describe('Moon phase (0.0 to 1.0)'),
    azimuthProfiles: z.array(z.any()).optional(),
    moonPath: z.array(z.any()).optional(),
    currentAltitude: z.number().describe('Elevation of the current location in meters'),
  })
  .openapi({
    description: 'Rich JSON format for web clients (Moon)',
    example: {
      moonsetTime: 1718000000,
      minutesToMoonset: 45,
      moonriseTime: 1718040000,
      minutesToMoonrise: 30,
      isPolar: false,
      fraction: 0.98,
      phase: 0.52,
      currentAltitude: 50,
    },
  });
