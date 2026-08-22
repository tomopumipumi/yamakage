import { Effect } from 'effect';
import { type ExecuteContext, executeWasmCalculation } from './WasmCalculationUtils';

export const calculateMoonShadow = (context: ExecuteContext) =>
  Effect.gen(function* (_) {
    const result = yield* _(executeWasmCalculation(context, 'moon'));

    if (result.type !== 'moon') throw new Error('Unexpected calculation type returned');

    return {
      isPolar: result.isPolar,
      moonsetResult: result.setResult,
      moonriseResult: result.riseResult,
      azimuthProfiles: result.azimuthProfiles,
      moonPath: result.path,
      currentAltitude: result.currentAltitude,
      fraction: result.fraction,
      phase: result.phase,
    };
  });
