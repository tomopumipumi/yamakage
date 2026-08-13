import type { Coordinate } from '../types/calculator';

export interface ElevationRepository {
  getElevations(points: Coordinate[]): Promise<Map<string, number>>;
}
