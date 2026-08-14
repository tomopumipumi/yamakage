import { Effect } from 'effect';
import init, { type InitOutput, ShadowEngine } from '../../../yamakage-wasm/pkg/yamakage_wasm';
import wasmModule from '../../../yamakage-wasm/pkg/yamakage_wasm_bg.wasm';

import { WasmError } from '../errors';
import { ElevationRepositoryService } from '../interfaces/ElevationRepository';
import { LoggerService } from '../interfaces/Logger';
import type { Coordinate } from '../types/calculator';

interface ExecuteContext {
  lat: number;
  lng: number;
  targetTime: Date;
  stepDeg: number;
  quality?: 0 | 1 | 2;
}

let wasmInstance: InitOutput | null = null;

const ensureWasmInitialized = Effect.gen(function* (_) {
  if (!wasmInstance) {
    wasmInstance = yield* _(
      Effect.tryPromise({
        try: () => init(wasmModule),
        catch: (e) => new WasmError('Failed to initialize Wasm module', e),
      }),
    );
  }
  return wasmInstance;
});

const generatePoints = (
  engine: ShadowEngine,
  wasm: InitOutput,
  lat: number,
  lng: number,
  stepDeg: number,
  quality: number,
) =>
  Effect.gen(function* (_) {
    const logger = yield* _(LoggerService);

    const t0 = performance.now();
    const pointCount = engine.generate_sampling_points(lat, lng, stepDeg, quality);
    const t1 = performance.now();

    logger.debug(`[Perf: Wasm CPU] Generated ${pointCount} points in ${(t1 - t0).toFixed(2)}ms`);

    const lats = new Float64Array(wasm.memory.buffer, engine.get_lats_ptr(), pointCount);
    const lngs = new Float64Array(wasm.memory.buffer, engine.get_lngs_ptr(), pointCount);

    const samplingPoints: Coordinate[] = [{ lat, lng }];
    for (let i = 0; i < pointCount; i++) {
      samplingPoints.push({ lat: lats[i], lng: lngs[i] });
    }

    return { pointCount, lats, lngs, samplingPoints };
  });

const writeElevationsToWasm = (
  engine: ShadowEngine,
  wasm: InitOutput,
  pointCount: number,
  lat: number,
  lng: number,
  lats: Float64Array,
  lngs: Float64Array,
  elevationsMap: Map<string, number>,
) =>
  Effect.sync(() => {
    const getIntCoord = (c: number) => Math.round(c * 1000000);
    const currentAltitude = elevationsMap.get(`${getIntCoord(lat)}_${getIntCoord(lng)}`) || 0;

    const elevationsWasmArray = new Float64Array(
      wasm.memory.buffer,
      engine.get_elevations_ptr(),
      pointCount,
    );

    for (let i = 0; i < pointCount; i++) {
      elevationsWasmArray[i] =
        elevationsMap.get(`${getIntCoord(lats[i])}_${getIntCoord(lngs[i])}`) || 0;
    }

    return currentAltitude;
  });

export const calculateShadow = ({ lat, lng, targetTime, stepDeg, quality = 1 }: ExecuteContext) =>
  Effect.gen(function* (_) {
    const logger = yield* _(LoggerService);
    const elevationRepo = yield* _(ElevationRepositoryService);

    logger.debug('Starting Wasm Shadow Calculation', { lat, lng, quality });
    const totalStart = performance.now();

    const currentWasm = yield* _(ensureWasmInitialized);

    const result = yield* _(
      Effect.acquireUseRelease(
        Effect.sync(() => new ShadowEngine()),
        (engine) =>
          Effect.gen(function* (_) {
            const { pointCount, lats, lngs, samplingPoints } = yield* _(
              generatePoints(engine, currentWasm, lat, lng, stepDeg, quality),
            );

            const t2 = performance.now();
            const elevationsMap = yield* _(elevationRepo.getElevations(samplingPoints));
            const t3 = performance.now();
            logger.debug(`[Perf: TS I/O] Fetched elevation data in ${(t3 - t2).toFixed(2)}ms`);

            const currentAltitude = yield* _(
              writeElevationsToWasm(
                engine,
                currentWasm,
                pointCount,
                lat,
                lng,
                lats,
                lngs,
                elevationsMap,
              ),
            );

            const t4 = performance.now();
            const res = engine.calculate_shadow(lat, lng, targetTime.getTime(), currentAltitude);
            const t5 = performance.now();
            logger.debug(
              `[Perf: Wasm CPU] Shadow calculation finished in ${(t5 - t4).toFixed(2)}ms`,
            );

            return res;
          }),
        (engine) => Effect.sync(() => engine.free()),
      ),
    );

    const totalEnd = performance.now();
    logger.info(
      `Wasm calculation completed successfully. Total: ${(totalEnd - totalStart).toFixed(2)}ms`,
    );

    return {
      isPolar: result.isPolar,
      sunsetResult:
        result.sunsetTimeUnix > 0
          ? { minutesToShadow: result.minutesToSunset, shadowTimeUnix: result.sunsetTimeUnix }
          : null,
      sunriseResult:
        result.sunriseTimeUnix > 0
          ? { minutesToSunrise: result.minutesToSunrise, sunriseTimeUnix: result.sunriseTimeUnix }
          : null,
      azimuthProfiles: result.azimuthProfiles,
      sunPath: result.sunPath,
    };
  });
