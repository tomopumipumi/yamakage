import type { Coordinate } from '../models/types';

export interface ElevationRepository {
  getElevations(points: Coordinate[]): Promise<Map<string, number>>;
}
