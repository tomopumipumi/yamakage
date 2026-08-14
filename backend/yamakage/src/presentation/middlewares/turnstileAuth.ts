import { Effect, Exit } from 'effect';
import type { Context, Next } from 'hono';
import type { Logger } from '../../application/interfaces/Logger';
import type { Bindings } from '../../types/env';

const TURNSTILE_VERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify';

class RateLimitError {
  readonly _tag = 'RateLimitError';
}
class MissingTokenError {
  readonly _tag = 'MissingTokenError';
}
class InvalidTokenError {
  readonly _tag = 'InvalidTokenError';
  constructor(readonly errorCodes: string[]) {}
}
class TurnstileNetworkError {
  readonly _tag = 'TurnstileNetworkError';
  constructor(readonly cause: unknown) {}
}

export const createTurnstileAuthMiddleware = (logger: Logger) => {
  return async (c: Context<{ Bindings: Bindings }>, next: Next) => {
    const token = c.req.header('X-Turnstile-Token');
    const clientIp = c.req.header('cf-connecting-ip') || 'unknown';

    const verifyProgram = Effect.gen(function* (_) {
      if (c.env.RATE_LIMITER) {
        const { success } = yield* _(
          Effect.promise(() => c.env.RATE_LIMITER.limit({ key: `web_${clientIp}` })),
        );
        if (!success) {
          logger.warn('Web API Rate Limit Exceeded', { clientIp });
          return yield* _(Effect.fail(new RateLimitError()));
        }
      }

      if (!token) {
        logger.warn('Turnstile Error: Missing token', { clientIp });
        return yield* _(Effect.fail(new MissingTokenError()));
      }

      const formData = new URLSearchParams();
      formData.append('secret', c.env.TURNSTILE_SECRET_KEY);
      formData.append('response', token);
      formData.append('remoteip', clientIp);

      const outcome = yield* _(
        Effect.tryPromise({
          try: async () => {
            const res = await fetch(TURNSTILE_VERIFY_URL, { method: 'POST', body: formData });
            return (await res.json()) as { success: boolean; 'error-codes': string[] };
          },
          catch: (e) => new TurnstileNetworkError(e),
        }),
      );

      if (!outcome.success) {
        logger.warn('Turnstile Error: Invalid token', {
          clientIp,
          errorCodes: outcome['error-codes'],
        });
        return yield* _(Effect.fail(new InvalidTokenError(outcome['error-codes'])));
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
        case 'RateLimitError':
          return c.json({ error: 'Too Many Requests' }, 429);
        case 'MissingTokenError':
          return c.json({ error: 'Unauthorized: Missing Turnstile token' }, 401);
        case 'InvalidTokenError':
          return c.json({ error: 'Forbidden: Invalid Turnstile token' }, 403);
        case 'TurnstileNetworkError':
          logger.error('Turnstile verification failed due to network error', error.cause, {
            clientIp,
          });
          return c.json({ error: 'Internal Server Error' }, 500);
      }
    }

    return c.json({ error: 'Internal Server Error' }, 500);
  };
};
