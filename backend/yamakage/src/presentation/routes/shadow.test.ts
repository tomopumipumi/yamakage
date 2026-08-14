import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import app from '../../index';

beforeAll(() => {
  vi.spyOn(console, 'debug').mockImplementation(() => {});
  vi.spyOn(console, 'info').mockImplementation(() => {});
  vi.spyOn(console, 'warn').mockImplementation(() => {});
  vi.spyOn(console, 'error').mockImplementation(() => {});
});

afterAll(() => {
  vi.restoreAllMocks();
});

const mockEnv = {
  YAMAKAGE_API_KEY: 'valid-api-key',
  RATE_LIMITER: {
    limit: async () => ({ success: true }),
  } as unknown as RateLimit,
  yamakage_terrain_tiles: {} as R2Bucket,
};

describe('GET /api/v1/shadow', () => {
  it('should return 401 if Authorization header is missing', async () => {
    const res = await app.request('/api/v1/shadow?lat=35&lng=135', {}, mockEnv);
    expect(res.status).toBe(401);
  });

  it('should return 401 if API key is invalid', async () => {
    const res = await app.request(
      '/api/v1/shadow?lat=35&lng=135',
      {
        headers: { Authorization: 'Bearer wrong-key' },
      },
      mockEnv,
    );
    expect(res.status).toBe(401);
  });

  it('should return 400 if lat is out of range', async () => {
    const res = await app.request(
      '/api/v1/shadow?lat=100&lng=135',
      {
        headers: { Authorization: `Bearer ${mockEnv.YAMAKAGE_API_KEY}` },
      },
      mockEnv,
    );
    expect(res.status).toBe(400);
  });

  it('should return 400 if lng is missing', async () => {
    const res = await app.request(
      '/api/v1/shadow?lat=35',
      {
        headers: { Authorization: `Bearer ${mockEnv.YAMAKAGE_API_KEY}` },
      },
      mockEnv,
    );
    expect(res.status).toBe(400);
  });

  it('should return 429 if rate limit is exceeded', async () => {
    const rateLimitedEnv = {
      ...mockEnv,
      RATE_LIMITER: { limit: async () => ({ success: false }) } as unknown as RateLimit,
    };
    const res = await app.request(
      '/api/v1/shadow?lat=35&lng=135',
      {
        headers: { Authorization: `Bearer ${mockEnv.YAMAKAGE_API_KEY}` },
      },
      rateLimitedEnv,
    );

    expect(res.status).toBe(429);
  });
});
