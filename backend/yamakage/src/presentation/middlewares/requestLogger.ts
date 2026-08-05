import type { Context, Next } from 'hono';
import type { Logger } from '../../application/interfaces/Logger';

export const requestLogger = (logger: Logger) => {
  return async (c: Context, next: Next) => {
    const start = Date.now();
    const { method, url } = c.req;
    const sessionId = c.req.header('X-Session-Id') || 'unknown';

    logger.info('Incoming Request', { method, url, sessionId });

    try {
      await next();
    } catch (error) {
      const ms = Date.now() - start;
      logger.error('Unhandled Exception during Request', error, {
        method,
        url,
        sessionId,
        durationMs: ms,
      });
      throw error;
    }

    const ms = Date.now() - start;
    const status = c.res.status;

    if (status >= 500) {
      logger.error('Request Server Error', undefined, {
        method,
        url,
        status,
        durationMs: ms,
        sessionId,
      });
    } else if (status >= 400) {
      logger.warn('Request Client Error', { method, url, status, durationMs: ms, sessionId });
    } else {
      logger.info('Request Completed', { method, url, status, durationMs: ms, sessionId });
    }
  };
};
