import { swaggerUI } from '@hono/swagger-ui';
import { OpenAPIHono } from '@hono/zod-openapi';
import { cors } from 'hono/cors';
import { ConsoleLogger } from './infrastructure/logging/ConsoleLogger';
import { requestLogger } from './presentation/middlewares/requestLogger';
import { createShadowRouter } from './presentation/routes/shadow';
import { createWatchAppShadowRouter } from './presentation/routes/watchAppShadow';
import { createWebShadowRouter } from './presentation/routes/webShadow';
import type { Bindings } from './types/env';

const logger = new ConsoleLogger();

const app = new OpenAPIHono<{ Bindings: Bindings }>({
  defaultHook: (result, c) => {
    if (!result.success) {
      const formattedErrors = result.error.issues.map((issue) => ({
        field: issue.path.join('.'),
        message: issue.message,
      }));

      logger.warn('Validation Error', {
        method: c.req.method,
        url: c.req.url,
        sessionId: c.req.header('X-Session-Id') || 'unknown',
        target: result.target,
        errors: formattedErrors,
      });

      return c.json({ error: 'Invalid parameters', details: formattedErrors }, 400);
    }
  },
});

app.use(
  '/api/v1/web/shadow/*',
  cors({
    origin: ['https://yamakage-site.pages.dev', 'http://localhost:5173'],
    allowHeaders: ['Content-Type', 'X-Turnstile-Token'],
    allowMethods: ['POST', 'GET', 'OPTIONS'],
  }),
);

app.use('*', requestLogger(logger));

// For Garmin (DataField)
app.openAPIRegistry.registerComponent('securitySchemes', 'BearerAuth', {
  type: 'http',
  scheme: 'bearer',
  description: 'Please enter your API key',
});

// For Garmin (WatchApp)
app.openAPIRegistry.registerComponent('securitySchemes', 'BearerAuth', {
  type: 'http',
  scheme: 'bearer',
  description: 'Please enter your API key',
});

// For Web
app.openAPIRegistry.registerComponent('securitySchemes', 'TurnstileAuth', {
  type: 'apiKey',
  in: 'header',
  name: 'X-Turnstile-Token',
  description: 'Cloudflare Turnstile response token',
});

app.doc('/doc', {
  openapi: '3.0.0',
  info: {
    version: '1.0.0',
    title: 'YAMAKAGE API',
    description: 'YAMAKAGE API is a lightweight BFF service for Garmin Edge devices...',
  },
});

app.get('/ui', swaggerUI({ url: '/doc' }));
app.get('/', (c) => c.text('YAMAKAGE API is running.'));

// For Garmin (DataField)
app.route('/api/v1/shadow', createShadowRouter(logger));
// For Garmin (WatchApp)
app.route('/api/v1/watchapp/shadow', createWatchAppShadowRouter(logger));
// For Web
app.route('/api/v1/web/shadow', createWebShadowRouter(logger));

export default app;
