import { Context, type Effect } from 'effect';
import type { ElevationFetchError } from '../errors';
import type { Coordinate } from '../types/calculator';
import type { Logger } from './Logger';

export interface ElevationRepository {
  getElevations(
    points: Coordinate[],
  ): Effect.Effect<Map<string, number>, ElevationFetchError, Logger>;
}

export const ElevationRepositoryService = Context.GenericTag<ElevationRepository>(
  '@app/ElevationRepository',
);
