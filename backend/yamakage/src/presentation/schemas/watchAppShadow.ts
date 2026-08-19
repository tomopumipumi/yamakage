import { z } from '@hono/zod-openapi';

export const WatchAppShadowRequestSchema = z.object({
  lat: z.coerce.number().min(-90).max(90).openapi({ example: 34.81 }),
  lng: z.coerce.number().min(-180).max(180).openapi({ example: 135.534 }),
  time: z.coerce.number().optional().openapi({ example: 1718000000000 }),
});

export const WatchAppShadowResponseSchema = z
  .object({
    d: z.tuple([
      z.number().describe('sunsetTime (Unix timestamp, -1 if none)'),
      z.number().describe('sunriseTime (Unix timestamp, -1 if none)'),
      z.number().describe('currentAltitude'),
      z.number().describe('azimuth step (e.g., 3 degrees)'),
      z
        .array(z.tuple([z.number(), z.number()]))
        .describe('azimuthProfiles [elevation, distance][]'),
      z
        .array(z.tuple([z.number(), z.number(), z.number()]))
        .describe('sunPaths [time, azimuth, altitude][]'),
    ]),
  })
  .openapi({
    description: 'Memory-optimized flat array response for Garmin Watch App',
    example: {
      d: [
        1718000000,
        1718040000,
        50.5,
        3,
        [
          [12.5, 5000],
          [13.1, 8500],
          [14.2, 12000],
        ],
        [
          [1718000000, 270.5, -0.8],
          [1718000600, 271.2, -1.5],
        ],
      ],
    },
  });
