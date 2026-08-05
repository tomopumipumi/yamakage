import { z } from '@hono/zod-openapi';

export const ShadowQuerySchema = z.object({
  lat: z.coerce
    .number()
    .min(-90)
    .max(90)
    .openapi({ param: { name: 'lat', in: 'query' }, example: 34.81 }),
  lng: z.coerce
    .number()
    .min(-180)
    .max(180)
    .openapi({ param: { name: 'lng', in: 'query' }, example: 135.534 }),
  time: z.coerce
    .number()
    .optional()
    .openapi({ param: { name: 'time', in: 'query' }, example: 1718000000000 }),
});

export const ShadowResponseSchema = z
  .object({
    d: z
      .tuple([
        z.number().describe('minutes_to_shadow'),
        z.number().describe('shadow_time'),
        z.number().describe('minutes_to_sunrise'),
        z.number().describe('sunrise_time'),
      ])
      .describe(
        'In index order: [minutes to sunset, sunset Unix time, minutes to sunrise, sunrise Unix time]',
      ),
  })
  .openapi({
    description:
      'Array data wrapped in a minimal key "d" to satisfy Garmin SDK specifications (root must be a Dictionary) and memory limits (32KB).',
    example: { d: [45, 1718000000, 30, 1718040000] },
  });
