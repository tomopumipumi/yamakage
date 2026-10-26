import { z } from '@hono/zod-openapi';

export const ComplicationRequestSchema = z.object({
  lat: z.coerce.number().min(-89.999).max(89.999).openapi({ example: 34.81 }),
  lng: z.coerce.number().min(-180).max(180).openapi({ example: 135.534 }),
  time: z.coerce.number().optional().openapi({ example: 1718000000000 }),
});

export const ComplicationResponseSchema = z
  .object({
    d: z.tuple([
      z.number().nullable().describe('Sunrise Time (Unix timestamp)'),
      z.number().nullable().describe('Sunset Time (Unix timestamp)'),
      z.number().nullable().describe('Moonrise Time (Unix timestamp)'),
      z.number().nullable().describe('Moonset Time (Unix timestamp)'),
      z.number().describe('Moon Phase (0.0 to 1.0)'),
      z.number().describe('Moon Fraction (0.0 to 1.0)'),
      z.number().describe('Current Altitude in meters'),
    ]),
  })
  .openapi({
    description: 'Ultra-lightweight JSON response for Garmin Background process (Complications)',
    example: {
      d: [1724832000, 1724871600, 1724850000, 1724880000, 0.52, 0.98, 50],
    },
  });
