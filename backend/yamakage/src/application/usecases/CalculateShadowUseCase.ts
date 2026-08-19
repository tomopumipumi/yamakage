import { Effect } from 'effect';
import init, { type InitOutput, ShadowEngine } from '../../../yamakage-wasm/pkg/yamakage_wasm';
import wasmModule from '../../../yamakage-wasm/pkg/yamakage_wasm_bg.wasm';

import { WasmError } from '../errors';
import { ElevationRepositoryService } from '../interfaces/ElevationRepository';
import { LoggerService } from '../interfaces/Logger';
import type { Coordinate, TerrainAzimuthProfile } from '../types/calculator';

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

const decodeTilesInWasm = (
  engine: ShadowEngine,
  wasm: InitOutput,
  tileResults: {
    buffer: ArrayBuffer | null;
    points: { index: number; px: number; py: number }[];
  }[],
) =>
  Effect.sync(() => {
    for (const tile of tileResults) {
      if (!tile.buffer) continue;

      const numPoints = tile.points.length;

      const pngSize = tile.buffer.byteLength;
      const pngPtr = engine.get_io_u8_ptr(pngSize);
      const wasmU8Array = new Uint8Array(wasm.memory.buffer, pngPtr, pngSize);
      wasmU8Array.set(new Uint8Array(tile.buffer));

      const pointsPtr = engine.get_io_u32_ptr(numPoints * 3);
      const wasmU32Array = new Uint32Array(wasm.memory.buffer, pointsPtr, numPoints * 3);

      for (let i = 0; i < numPoints; i++) {
        wasmU32Array[i * 3] = tile.points[i].index;
        wasmU32Array[i * 3 + 1] = tile.points[i].px;
        wasmU32Array[i * 3 + 2] = tile.points[i].py;
      }

      engine.decode_tile_elevations(pngSize, numPoints);
    }
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
            const t0 = performance.now();
            const pointCount = engine.generate_sampling_points(lat, lng, stepDeg, quality);
            const t1 = performance.now();
            logger.debug(
              `[Perf: Wasm CPU] Generated ${pointCount} points in ${(t1 - t0).toFixed(2)}ms`,
            );

            const lats = new Float64Array(
              currentWasm.memory.buffer,
              engine.get_lats_ptr(),
              pointCount,
            );
            const lngs = new Float64Array(
              currentWasm.memory.buffer,
              engine.get_lngs_ptr(),
              pointCount,
            );

            const samplingPoints: Coordinate[] = new Array(pointCount + 1);
            samplingPoints[0] = { lat, lng };
            for (let i = 0; i < pointCount; i++) {
              samplingPoints[i + 1] = { lat: lats[i], lng: lngs[i] };
            }

            const t2 = performance.now();
            const tileResults = yield* _(elevationRepo.fetchTileData(samplingPoints));
            const t3 = performance.now();
            logger.debug(`[Perf: TS I/O] Fetched tile data in ${(t3 - t2).toFixed(2)}ms`);

            const t3_5 = performance.now();
            yield* _(decodeTilesInWasm(engine, currentWasm, tileResults));
            const t4 = performance.now();
            logger.debug(`[Perf: Wasm CPU] Decoded PNG tiles in ${(t4 - t3_5).toFixed(2)}ms`);

            const currentAltitude = engine.get_center_elevation();

            const resultPtr = engine.calculate_shadow(
              lat,
              lng,
              targetTime.getTime(),
              currentAltitude,
            ) as unknown as number;

            const t5 = performance.now();
            logger.debug(
              `[Perf: Wasm CPU] Shadow calculation finished in ${(t5 - t4).toFixed(2)}ms`,
            );

            const headerArray = new Float64Array(currentWasm.memory.buffer, resultPtr, 8);
            if (Number.isNaN(headerArray[0])) {
              return yield* _(
                Effect.fail(new WasmError('Invalid coordinates or calculation context')),
              );
            }

            const isPolar = headerArray[0] === 1.0;
            const sunsetTimeUnix = headerArray[1];
            const minutesToSunset = headerArray[2];
            const sunriseTimeUnix = headerArray[3];
            const minutesToSunrise = headerArray[4];
            const numProfiles = headerArray[5];
            const numSunPath = headerArray[6];

            const profilesOffset = resultPtr + 8 * 8;
            const profilesArray = new Float64Array(
              currentWasm.memory.buffer,
              profilesOffset,
              numProfiles * 6,
            );
            const azimuthProfiles: TerrainAzimuthProfile[] = [];

            for (let i = 0; i < numProfiles; i++) {
              const azimuthDeg = profilesArray[i * 6];
              const maxObstacleAngleDeg = profilesArray[i * 6 + 1];
              const hLat = profilesArray[i * 6 + 2];
              const hLng = profilesArray[i * 6 + 3];
              const highestAltitude = profilesArray[i * 6 + 4];
              const distance = profilesArray[i * 6 + 5];

              let highestPoint: Coordinate | undefined;

              if (!Number.isNaN(hLat) && !Number.isNaN(hLng)) {
                highestPoint = { lat: hLat, lng: hLng };
              }

              azimuthProfiles.push({
                azimuthDeg,
                maxObstacleAngleDeg,
                highestPoint,
                highestAltitude,
                distance,
              });
            }

            const sunPathOffset = profilesOffset + numProfiles * 6 * 8;
            const sunPathArray = new Float64Array(
              currentWasm.memory.buffer,
              sunPathOffset,
              numSunPath * 3,
            );
            const sunPath: { time: number; azimuth: number; altitude: number }[] = [];

            for (let i = 0; i < numSunPath; i++) {
              sunPath.push({
                time: sunPathArray[i * 3],
                azimuth: sunPathArray[i * 3 + 1],
                altitude: sunPathArray[i * 3 + 2],
              });
            }

            return {
              isPolar,
              sunsetResult:
                sunsetTimeUnix > 0
                  ? { minutesToShadow: minutesToSunset, shadowTimeUnix: sunsetTimeUnix }
                  : null,
              sunriseResult:
                sunriseTimeUnix > 0
                  ? { minutesToSunrise: minutesToSunrise, sunriseTimeUnix: sunriseTimeUnix }
                  : null,
              azimuthProfiles,
              sunPath,
              currentAltitude,
            };
          }),
        (engine) => Effect.sync(() => engine.free()),
      ),
    );

    const totalEnd = performance.now();
    logger.info(
      `Wasm calculation completed successfully. Total: ${(totalEnd - totalStart).toFixed(2)}ms`,
    );

    return result;
  });
