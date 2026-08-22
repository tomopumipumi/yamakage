import { Effect } from 'effect';
import init, { type InitOutput, ShadowEngine } from '../../../yamakage-wasm/pkg/yamakage_wasm';
import wasmModule from '../../../yamakage-wasm/pkg/yamakage_wasm_bg.wasm';

import { WasmError } from '../errors';
import { ElevationRepositoryService } from '../interfaces/ElevationRepository';
import { LoggerService } from '../interfaces/Logger';
import type { Coordinate, TerrainAzimuthProfile } from '../types/calculator';

export interface ExecuteContext {
  lat: number;
  lng: number;
  targetTime: Date;
  stepDeg: number;
  quality?: 0 | 1 | 2;
}

export type CalculationType = 'sun' | 'moon';

const AZIMUTH_PROFILE_STRIDE = 6; // [azimuth, maxAngle, lat, lng, altitude, distance]
const PATH_POINT_STRIDE = 3; // [time, azimuth, altitude]
const SUN_HEADER_SIZE = 8;
const MOON_HEADER_SIZE = 9;

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

export const executeWasmCalculation = (
  { lat, lng, targetTime, stepDeg, quality = 1 }: ExecuteContext,
  calculationType: CalculationType,
) =>
  Effect.gen(function* (_) {
    const logger = yield* _(LoggerService);
    const elevationRepo = yield* _(ElevationRepositoryService);

    logger.debug(`Starting Wasm ${calculationType} Calculation`, { lat, lng, quality });
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
            const targetTimeMs = targetTime.getTime();

            const resultPtr =
              calculationType === 'sun'
                ? (engine.calculate_shadow(
                    lat,
                    lng,
                    targetTimeMs,
                    currentAltitude,
                  ) as unknown as number)
                : (engine.calculate_moon_shadow(
                    lat,
                    lng,
                    targetTimeMs,
                    currentAltitude,
                  ) as unknown as number);

            const t5 = performance.now();
            logger.debug(
              `[Perf: Wasm CPU] ${calculationType} calculation finished in ${(t5 - t4).toFixed(2)}ms`,
            );

            const headerSize = calculationType === 'sun' ? SUN_HEADER_SIZE : MOON_HEADER_SIZE;
            const headerArray = new Float64Array(currentWasm.memory.buffer, resultPtr, headerSize);

            if (Number.isNaN(headerArray[0])) {
              return yield* _(
                Effect.fail(new WasmError('Invalid coordinates or calculation context')),
              );
            }

            const isPolar = headerArray[0] === 1.0;
            const setTimeUnix = headerArray[1];
            const minutesToSet = headerArray[2];
            const riseTimeUnix = headerArray[3];
            const minutesToRise = headerArray[4];
            const numProfiles = headerArray[5];
            const numPath = headerArray[6];

            const profilesOffset = resultPtr + headerSize * Float64Array.BYTES_PER_ELEMENT;
            const profilesArray = new Float64Array(
              currentWasm.memory.buffer,
              profilesOffset,
              numProfiles * AZIMUTH_PROFILE_STRIDE,
            );
            const azimuthProfiles: TerrainAzimuthProfile[] = [];

            for (let i = 0; i < numProfiles; i++) {
              const baseIndex = i * AZIMUTH_PROFILE_STRIDE;
              const azimuthDeg = profilesArray[baseIndex];
              const maxObstacleAngleDeg = profilesArray[baseIndex + 1];
              const hLat = profilesArray[baseIndex + 2];
              const hLng = profilesArray[baseIndex + 3];
              const highestAltitude = profilesArray[baseIndex + 4];
              const distance = profilesArray[baseIndex + 5];

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

            const pathOffset =
              profilesOffset +
              numProfiles * AZIMUTH_PROFILE_STRIDE * Float64Array.BYTES_PER_ELEMENT;
            const pathArray = new Float64Array(
              currentWasm.memory.buffer,
              pathOffset,
              numPath * PATH_POINT_STRIDE,
            );
            const path: { time: number; azimuth: number; altitude: number }[] = [];

            for (let i = 0; i < numPath; i++) {
              const baseIndex = i * PATH_POINT_STRIDE;
              path.push({
                time: pathArray[baseIndex],
                azimuth: pathArray[baseIndex + 1],
                altitude: pathArray[baseIndex + 2],
              });
            }

            const baseResult = {
              isPolar,
              setResult:
                setTimeUnix > 0
                  ? { minutesToShadow: minutesToSet, shadowTimeUnix: setTimeUnix }
                  : null,
              riseResult:
                riseTimeUnix > 0
                  ? { minutesToSunrise: minutesToRise, sunriseTimeUnix: riseTimeUnix }
                  : null,
              azimuthProfiles,
              path,
              currentAltitude,
            };

            if (calculationType === 'sun') {
              return { ...baseResult, type: 'sun' as const };
            } else {
              const fraction = headerArray[7];
              const phase = headerArray[8];
              return { ...baseResult, fraction, phase, type: 'moon' as const };
            }
          }),
        (engine) => Effect.sync(() => engine.free()),
      ),
    );

    const totalEnd = performance.now();
    logger.info(
      `Wasm ${calculationType} calculation completed successfully. Total: ${(totalEnd - totalStart).toFixed(2)}ms`,
    );

    return result;
  });
