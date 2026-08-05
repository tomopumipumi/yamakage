import type { Context, Next } from 'hono';
import type { Logger } from '../../application/interfaces/Logger';
import type { Bindings } from '../../types/env';

export const createAuthMiddleware = (logger: Logger) => {
  return async (c: Context<{ Bindings: Bindings }>, next: Next) => {
    const sessionId = c.req.header('X-Session-Id') || 'unknown';
    const authHeader = c.req.header('Authorization');

    if (!authHeader || authHeader !== `Bearer ${c.env.YAMAKAGE_API_KEY}`) {
      logger.warn('Auth Error: Unauthorized access attempt', { sessionId });
      return c.json({ error: 'Unauthorized' }, 401);
    }

    if (c.env.RATE_LIMITER) {
      const { success } = await c.env.RATE_LIMITER.limit({ key: sessionId });
      if (!success) {
        logger.warn('Rate Limit Exceeded', { sessionId });
        return c.json({ error: 'Too Many Requests' }, 429);
      }
    }

    await next();
  };
};
