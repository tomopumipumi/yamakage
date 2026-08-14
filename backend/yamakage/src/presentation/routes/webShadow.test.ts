import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from 'vitest';
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
  TURNSTILE_SECRET_KEY: 'test-secret',
  RATE_LIMITER: {
    limit: async () => ({ success: true }),
  } as unknown as RateLimit,
  yamakage_terrain_tiles: {} as R2Bucket,
};

describe('POST /api/v1/web/shadow', () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('should return 401 if Turnstile token is missing', async () => {
    const res = await app.request(
      '/api/v1/web/shadow',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lat: 35, lng: 135 }),
      },
      mockEnv,
    );
    expect(res.status).toBe(401);
  });

  it('should return 403 if Turnstile verification fails', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      json: async () => ({ success: false, 'error-codes': ['invalid-input-response'] }),
    });
    vi.stubGlobal('fetch', fetchMock);

    const res = await app.request(
      '/api/v1/web/shadow',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Turnstile-Token': 'invalid-token',
        },
        body: JSON.stringify({ lat: 35, lng: 135 }),
      },
      mockEnv,
    );

    expect(res.status).toBe(403);
    expect(fetchMock).toHaveBeenCalled();
  });

  it('should return 400 if Turnstile succeeds but JSON body is invalid', async () => {
    const fetchMock = vi.fn().mockResolvedValue({
      json: async () => ({ success: true }),
    });
    vi.stubGlobal('fetch', fetchMock);

    const res = await app.request(
      '/api/v1/web/shadow',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Turnstile-Token': 'valid-token',
        },
        body: JSON.stringify({ lat: 'invalid_string', lng: 135 }),
      },
      mockEnv,
    );

    expect(res.status).toBe(400);
  });
});
