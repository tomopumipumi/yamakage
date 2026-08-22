import { Effect } from 'effect';
import { type ExecuteContext, executeWasmCalculation } from './WasmCalculationUtils';

export const calculateShadow = (context: ExecuteContext) =>
  Effect.gen(function* (_) {
    const result = yield* _(executeWasmCalculation(context, 'sun'));

    return {
      isPolar: result.isPolar,
      sunsetResult: result.setResult,
      sunriseResult: result.riseResult,
      azimuthProfiles: result.azimuthProfiles,
      sunPath: result.path,
      currentAltitude: result.currentAltitude,
    };
  });
