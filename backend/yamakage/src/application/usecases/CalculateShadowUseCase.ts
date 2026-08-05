import * as SunCalc from 'suncalc';
import { ShadowCalculationEngine } from '../../domain/engines/ShadowCalculationEngine';
import { TerrainProfileEngine } from '../../domain/engines/TerrainProfileEngine';
import { TerrainSamplingEngine } from '../../domain/engines/TerrainSamplingEngine';
import type { ShadowCalculationResult, SunriseCalculationResult } from '../../domain/models/types';
import type { ElevationRepository } from '../../domain/repositories/ElevationRepository';
import type { Logger } from '../interfaces/Logger';

export interface CalculateShadowUseCaseProps {
  elevationRepository: ElevationRepository;
  logger: Logger;
}

export interface calcExecuterAsync {
  isPolar: boolean;
  sunsetResult: ShadowCalculationResult | null;
  sunriseResult: SunriseCalculationResult | null;
}

export const createCalculateShadowUseCase = ({
  elevationRepository,
  logger,
}: CalculateShadowUseCaseProps) => {
  return async (lat: number, lng: number, targetTime: Date): Promise<calcExecuterAsync> => {
    logger.debug('Starting Shadow Calculation', { lat, lng, targetTime: targetTime.toISOString() });
    const times = SunCalc.getTimes(targetTime, lat, lng);

    if (!times.sunset || !times.sunrise) {
      logger.info('Detected polar day/night. Calculation skipped.', { lat, lng });
      return { isPolar: true, sunsetResult: null, sunriseResult: null };
    }

    const fullPanorama = TerrainSamplingEngine.generateFullPanorama(lat, lng, 15);

    const allSamplingPoints = [{ lat, lng, distance: 0 }, ...fullPanorama.flatMap((p) => p.points)];

    logger.debug('Sampling points generated', { totalPoints: allSamplingPoints.length });

    const elevationsMap = await elevationRepository.getElevations(allSamplingPoints);

    const fullAzimuthProfiles = TerrainProfileEngine.buildAzimuthProfiles(
      lat,
      lng,
      fullPanorama,
      elevationsMap,
    );

    const sunsetResult = ShadowCalculationEngine.calculateTrueSunset(
      lat,
      lng,
      targetTime,
      fullAzimuthProfiles,
    );
    const sunriseResult = ShadowCalculationEngine.calculateTrueSunrise(
      lat,
      lng,
      targetTime,
      fullAzimuthProfiles,
    );

    logger.info('Shadow calculation completed successfully', {
      minutesToSunsetShadow: sunsetResult.minutesToShadow,
      minutesToSunriseShadow: sunriseResult.minutesToSunrise,
    });

    return { isPolar: false, sunsetResult, sunriseResult };
  };
};
