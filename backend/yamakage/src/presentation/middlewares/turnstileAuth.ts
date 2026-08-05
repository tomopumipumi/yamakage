import type { Context, Next } from 'hono';
import type { Logger } from '../../application/interfaces/Logger';
import type { Bindings } from '../../types/env';

const TURNSTILE_VERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';

export const createTurnstileAuthMiddleware = (logger: Logger) => {
  return async (c: Context<{ Bindings: Bindings }>, next: Next) => {
    const token = c.req.header('X-Turnstile-Token');
    
    const clientIp = c.req.header('cf-connecting-ip') || 'unknown';

    if (c.env.RATE_LIMITER) {
      const { success } = await c.env.RATE_LIMITER.limit({ key: `web_${clientIp}` });
      if (!success) {
        logger.warn('Web API Rate Limit Exceeded', { clientIp });
        return c.json({ error: 'Too Many Requests' }, 429);
      }
    }

    if (!token) {
      logger.warn('Turnstile Error: Missing token', { clientIp });
      return c.json({ error: 'Unauthorized: Missing Turnstile token' }, 401);
    }

    try {
      const formData = new URLSearchParams();
      formData.append('secret', c.env.TURNSTILE_SECRET_KEY);
      formData.append('response', token);
      formData.append('remoteip', clientIp);

      const result = await fetch(TURNSTILE_VERIFY_URL, {
        method: 'POST',
        body: formData,
      });

      const outcome = await result.json() as { success: boolean; 'error-codes': string[] };

      if (!outcome.success) {
        logger.warn('Turnstile Error: Invalid token', { 
          clientIp, 
          errorCodes: outcome['error-codes'] 
        });
        return c.json({ error: 'Forbidden: Invalid Turnstile token' }, 403);
      }
    } catch (error) {
      logger.error('Turnstile verification failed due to network error', error, { clientIp });
      return c.json({ error: 'Internal Server Error' }, 500);
    }

    await next();
  };
};