import { swaggerUI } from '@hono/swagger-ui';
import { OpenAPIHono } from '@hono/zod-openapi';
import { ConsoleLogger } from './infrastructure/logging/ConsoleLogger';
import { requestLogger } from './presentation/middlewares/requestLogger';
import { createShadowRouter } from './presentation/routes/shadow';
import type { Bindings } from './types/env';

const app = new OpenAPIHono<{ Bindings: Bindings }>();

const logger = new ConsoleLogger();

app.use('*', requestLogger(logger));

app.openAPIRegistry.registerComponent('securitySchemes', 'BearerAuth', {
  type: 'http',
  scheme: 'bearer',
  description: 'Please enter your API key',
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

app.route('/api/v1/shadow', createShadowRouter(logger));

export default app;
