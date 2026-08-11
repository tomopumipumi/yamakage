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

interface CalculateShadowUseCaseProps {
  elevationRepository: ElevationRepository;
  logger: Logger;
}

interface executeContext {
  lat: number;
  lng: number;
  targetTime: Date;
  stepDeg: number;
}

interface CalculateShadowExecuter {
  executeAsync: ({ lat, lng, targetTime, stepDeg }: executeContext) => Promise<ShadowExecuteResult>;
}

interface ShadowExecuteResult {
  isPolar: boolean;
  sunsetResult: ShadowCalculationResult | null;
  sunriseResult: SunriseCalculationResult | null;
  azimuthProfiles?: TerrainAzimuthProfile[];
  sunPath?: { time: number; azimuth: number; altitude: number }[];
}

export const createCalculateShadowUseCase = ({
  elevationRepository,
  logger,
}: CalculateShadowUseCaseProps): CalculateShadowExecuter => {
  const executeAsync = async ({
    lat,
    lng,
    targetTime,
    stepDeg,
  }: executeContext): Promise<ShadowExecuteResult> => {
    logger.debug('Starting Shadow Calculation', { lat, lng, targetTime: targetTime.toISOString() });
    const totalStart = performance.now();

    const times = SunCalc.getTimes(targetTime, lat, lng);
    const isPolar = !times.sunset || !times.sunrise;
    if (isPolar) {
      logger.info('Detected polar day/night. Calculation skipped.', { lat, lng });
      return { isPolar: true, sunsetResult: null, sunriseResult: null };
    }


    // Generate sampling points for the terrain profile
    const t0 = performance.now();
    const fullPanorama = TerrainSamplingEngine.generateFullPanorama(lat, lng, stepDeg);
    const allSamplingPoints = [{ lat, lng, distance: 0 }, ...fullPanorama.flatMap((p) => p.points)];
    const t1 = performance.now();
    logger.debug(`[Perf: CPU] 1. Sampling points generated in ${(t1 - t0).toFixed(2)}ms`, { totalPoints: allSamplingPoints.length });


    // Fetch elevation data for all sampling points
    const t2 = performance.now();
    const elevationsMap = await elevationRepository.getElevations(allSamplingPoints);
    const t3 = performance.now();
    logger.debug(`[Perf: I/O] 2. Elevation data fetched in ${(t3 - t2).toFixed(2)}ms`);


    // Build azimuth profiles from the fetched elevation data
    const t4 = performance.now();
    const fullAzimuthProfiles = TerrainProfileEngine.buildAzimuthProfiles(
      lat,
      lng,
      fullPanorama,
      elevationsMap,
    );
    const t5 = performance.now();
    logger.debug(`[Perf: CPU] 3. Azimuth profiles built in ${(t5 - t4).toFixed(2)}ms`);


    // Calculate true sunset and sunrise times based on the azimuth profiles
    const t6 = performance.now();
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
    const t7 = performance.now();
    logger.debug(`[Perf: CPU] 4. Shadow crossing calculated in ${(t7 - t6).toFixed(2)}ms`);


    // Calculate the sun's path for visualization purposes
    const t8 = performance.now();
    const sunPath: { time: number; azimuth: number; altitude: number }[] = [];
    const baseTime = targetTime.getTime();
    // Loop from -720 minutes (-12 hours) to +720 minutes (+12 hours)
    for (let i = -72; i <= 72; i++) {
      const t = new Date(baseTime + i * 10 * 60000); // 10-minute intervals

      const pos = SunPositionEngine.getPosition(t, lat, lng);

      // Extract points where the sun is above -15 degrees,
      // as lower positions are not needed for chart rendering.
      if (pos.altitudeDeg > -15) {
        sunPath.push({
          time: Math.floor(t.getTime() / 1000),
          azimuth: pos.azimuthDeg,
          altitude: pos.altitudeDeg,
        });
      }
    }
    const t9 = performance.now();
    logger.debug(`[Perf: CPU] 5. Sun path calculated in ${(t9 - t8).toFixed(2)}ms`);


    const totalEnd = performance.now();
    logger.info(`Shadow calculation completed successfully. Total Time: ${(totalEnd - totalStart).toFixed(2)}ms`, {
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

  return { executeAsync };
};
