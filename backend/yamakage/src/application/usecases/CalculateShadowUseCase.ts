import * as SunCalc from 'suncalc';
import { ShadowCalculationEngine } from '../../domain/engines/ShadowCalculationEngine';
import { SunPositionEngine } from '../../domain/engines/SunPositionEngine';
import { TerrainProfileEngine } from '../../domain/engines/TerrainProfileEngine';
import { TerrainSamplingEngine } from '../../domain/engines/TerrainSamplingEngine';
import type {
  ShadowCalculationResult,
  SunriseCalculationResult,
  TerrainAzimuthProfile,
} from '../../domain/models/types';
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
  azimuthProfiles?: TerrainAzimuthProfile[];
  sunPath?: { time: number; azimuth: number; altitude: number }[];
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

    const sunPath: { time: number; azimuth: number; altitude: number }[] = [];
    const baseTime = targetTime.getTime();
    for (let i = -72; i <= 72; i++) {
      const t = new Date(baseTime + i * 10 * 60000);

      const pos = SunPositionEngine.getPosition(t, lat, lng);

      if (pos.altitudeDeg > -15) {
        sunPath.push({
          time: Math.floor(t.getTime() / 1000),
          azimuth: pos.azimuthDeg,
          altitude: pos.altitudeDeg,
        });
      }
    }

    logger.info('Shadow calculation completed successfully', {
      minutesToSunsetShadow: sunsetResult.minutesToShadow,
      minutesToSunriseShadow: sunriseResult.minutesToSunrise,
    });

    return {
      isPolar: false,
      sunsetResult,
      sunriseResult,
      azimuthProfiles: fullAzimuthProfiles,
      sunPath,
    };
  };
};
