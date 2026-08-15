import { Context, type Effect } from 'effect';
import type { ElevationFetchError } from '../errors';
import type { Coordinate } from '../types/calculator';
import type { Logger } from './Logger';

export interface TileFetchResult {
  buffer: ArrayBuffer | null;
  points: { index: number; px: number; py: number }[];
}

export interface ElevationRepository {
  fetchTileData(
    points: Coordinate[],
  ): Effect.Effect<TileFetchResult[], ElevationFetchError, Logger>;
}

export const ElevationRepositoryService = Context.GenericTag<ElevationRepository>(
  '@app/ElevationRepository',
);
