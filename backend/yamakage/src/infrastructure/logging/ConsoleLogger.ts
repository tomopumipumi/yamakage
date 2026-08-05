import type { Logger } from '../../application/interfaces/Logger';

export class ConsoleLogger implements Logger {
  private formatMessage(
    level: string,
    message: string,
    context?: Record<string, unknown>,
    error?: unknown,
  ): string {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      ...(context && Object.keys(context).length > 0 ? { context } : {}),
      ...(error
        ? { error: error instanceof Error ? { message: error.message, stack: error.stack } : error }
        : {}),
    };
    return JSON.stringify(logEntry);
  }

  debug(message: string, context?: Record<string, unknown>): void {
    console.debug(this.formatMessage('DEBUG', message, context));
  }

  info(message: string, context?: Record<string, unknown>): void {
    console.info(this.formatMessage('INFO', message, context));
  }

  warn(message: string, context?: Record<string, unknown>): void {
    console.warn(this.formatMessage('WARN', message, context));
  }

  error(message: string, error?: unknown, context?: Record<string, unknown>): void {
    console.error(this.formatMessage('ERROR', message, context, error));
  }
}
