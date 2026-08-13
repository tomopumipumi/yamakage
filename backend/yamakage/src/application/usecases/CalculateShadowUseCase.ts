import init, { type InitOutput, ShadowEngine } from '../../../yamakage-wasm/pkg/yamakage_wasm';
import wasmModule from '../../../yamakage-wasm/pkg/yamakage_wasm_bg.wasm';

import type { ElevationRepository } from '../../application/interfaces/ElevationRepository';
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
  quality?: 0 | 1 | 2;
}

let wasmInstance: InitOutput | null = null;

export const createCalculateShadowUseCase = ({
  elevationRepository,
  logger,
}: CalculateShadowUseCaseProps) => {
  const executeAsync = async ({ lat, lng, targetTime, stepDeg, quality = 1 }: executeContext) => {
    logger.debug('Starting Wasm Shadow Calculation', { lat, lng, quality });
    const totalStart = performance.now();

    if (!wasmInstance) wasmInstance = await init(wasmModule);

    const engine = new ShadowEngine();

    try {
      const t0 = performance.now();
      const pointCount = engine.generate_sampling_points(lat, lng, stepDeg, quality);
      const t1 = performance.now();
      logger.debug(`[Perf: Wasm CPU] Generated ${pointCount} points in ${(t1 - t0).toFixed(2)}ms`);

      const lats = new Float64Array(wasmInstance.memory.buffer, engine.get_lats_ptr(), pointCount);
      const lngs = new Float64Array(wasmInstance.memory.buffer, engine.get_lngs_ptr(), pointCount);

      const allSamplingPoints = [{ lat, lng, distance: 0 }];
      for (let i = 0; i < pointCount; i++) {
        allSamplingPoints.push({ lat: lats[i], lng: lngs[i], distance: 0 });
      }

      const t2 = performance.now();
      const elevationsMap = await elevationRepository.getElevations(allSamplingPoints);
      const t3 = performance.now();
      logger.debug(`[Perf: TS I/O] Fetched elevation data in ${(t3 - t2).toFixed(2)}ms`);

      const getIntCoord = (c: number) => Math.round(c * 1000000);
      const currentAltitude = elevationsMap.get(`${getIntCoord(lat)}_${getIntCoord(lng)}`) || 0;

      const elevations = new Float64Array(
        wasmInstance.memory.buffer,
        engine.get_elevations_ptr(),
        pointCount,
      );
      for (let i = 0; i < pointCount; i++) {
        const alt = elevationsMap.get(`${getIntCoord(lats[i])}_${getIntCoord(lngs[i])}`) || 0;
        elevations[i] = alt;
      }

      const t4 = performance.now();
      const result = engine.calculate_shadow(lat, lng, targetTime.getTime(), currentAltitude);
      const t5 = performance.now();
      logger.debug(`[Perf: Wasm CPU] Shadow calculation finished in ${(t5 - t4).toFixed(2)}ms`);

      const totalEnd = performance.now();
      logger.info(
        `Wasm calculation completed successfully. Total: ${(totalEnd - totalStart).toFixed(2)}ms`,
      );

      return {
        isPolar: result.isPolar,
        sunsetResult:
          result.sunsetTimeUnix > 0
            ? {
                minutesToShadow: result.minutesToSunset,
                shadowTimeUnix: result.sunsetTimeUnix,
              }
            : null,
        sunriseResult:
          result.sunriseTimeUnix > 0
            ? {
                minutesToSunrise: result.minutesToSunrise,
                sunriseTimeUnix: result.sunriseTimeUnix,
              }
            : null,
        azimuthProfiles: result.azimuthProfiles,
        sunPath: result.sunPath,
      };
    } finally {
      engine.free();
    }
  };

  return { executeAsync };
};
