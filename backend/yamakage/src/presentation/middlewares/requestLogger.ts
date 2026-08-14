import { Cause, Effect, Exit } from 'effect';
import type { Context, Next } from 'hono';
import type { Logger } from '../../application/interfaces/Logger';

export const requestLogger = (logger: Logger) => {
  return async (c: Context, next: Next) => {
    const { method, url } = c.req;
    const sessionId = c.req.header('X-Session-Id') || 'unknown';

    const program = Effect.gen(function* (_) {
      const start = Date.now();
      logger.info('Incoming Request', { method, url, sessionId });

      yield* _(
        Effect.tryPromise({
          try: () => next(),
          catch: (e) => e,
        }).pipe(
          Effect.tapError((error) =>
            Effect.sync(() => {
              const ms = Date.now() - start;
              logger.error('Unhandled Exception during Request', error, {
                method,
                url,
                sessionId,
                durationMs: ms,
              });
            }),
          ),
        ),
      );

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
    });

    const exit = await Effect.runPromiseExit(program);

    if (Exit.isFailure(exit)) throw Cause.squash(exit.cause);
  };
};
