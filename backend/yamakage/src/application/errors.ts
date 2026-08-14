export class ElevationFetchError {
  readonly _tag = 'ElevationFetchError';
  constructor(
    readonly message: string,
    readonly cause?: unknown,
  ) {}
}

export class WasmError {
  readonly _tag = 'WasmError';
  constructor(
    readonly message: string,
    readonly cause?: unknown,
  ) {}
}
