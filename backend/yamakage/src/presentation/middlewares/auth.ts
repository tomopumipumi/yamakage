import { Effect, Exit } from 'effect';
import type { Context, Next } from 'hono';
import type { Logger } from '../../application/interfaces/Logger';
import type { Bindings } from '../../types/env';

class UnauthorizedError {
  readonly _tag = 'UnauthorizedError';
}
class RateLimitError {
  readonly _tag = 'RateLimitError';
}

export const createAuthMiddleware = (logger: Logger) => {
  return async (c: Context<{ Bindings: Bindings }>, next: Next) => {
    const sessionId = c.req.header('X-Session-Id') || 'unknown';
    const authHeader = c.req.header('Authorization');

    const verifyProgram = Effect.gen(function* (_) {
      if (!authHeader || authHeader !== `Bearer ${c.env.YAMAKAGE_API_KEY}`) {
        logger.warn('Auth Error: Unauthorized access attempt', { sessionId });
        return yield* _(Effect.fail(new UnauthorizedError()));
      }

      if (c.env.RATE_LIMITER) {
        const { success } = yield* _(
          Effect.promise(() => c.env.RATE_LIMITER.limit({ key: sessionId })),
        );
        if (!success) {
          logger.warn('Rate Limit Exceeded', { sessionId });
          return yield* _(Effect.fail(new RateLimitError()));
        }
      }
    });

    const exit = await Effect.runPromiseExit(verifyProgram);

    if (Exit.isSuccess(exit)) {
      await next();
      return;
    }

    if (exit.cause._tag === 'Fail') {
      const error = exit.cause.error;
      switch (error._tag) {
        case 'UnauthorizedError':
          return c.json({ error: 'Unauthorized' }, 401);
        case 'RateLimitError':
          return c.json({ error: 'Too Many Requests' }, 429);
      }
    }

    return c.json({ error: 'Internal Server Error' }, 500);
  };
};
