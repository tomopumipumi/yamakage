# ADR 004: Adoption of Effect (effect-ts) as the Foundation of the Application Layer

## Context

In the YAMAKAGE API backend (Cloudflare Workers), there were requirements where multiple asynchronous operations and resource management were complexly intertwined, as shown below:

### 1. **Complex Async I/O Orchestration**:

- Accessing Cloudflare R2 (cache).
- Fetching PNG tile images from AWS Open Data (S3) when not found in R2, and asynchronously saving to cache in the background using `waitUntil`.
- Concurrent processing of multiple tiles.

### 2. **Necessity of Reliable Resource Release**:

- Since WebAssembly (Wasm) was adopted as the core calculation engine, it was necessary to reliably release the Wasm instances created on the TypeScript side (`engine.free()`) after processing completed (or when an error occurred) to prevent memory leaks.

### 3. **Uncertainty of Error Handling**:

- With standard `Promise` and `try/catch`, the type of error a function might throw is not guaranteed at the TypeScript type level (it is always `unknown`). There were concerns about API server crashes (unexpected 500 errors) caused by unhandled errors.

### 4. **Separation of Cloudflare Environment Dependencies (DI)**:

- There was a need for a design (Dependency Injection: DI) that made testing and mocking easy, without tightly coupling environment variables (Bindings), loggers, and infrastructure repositories directly to the business logic (use cases).

## Decision

To comprehensively and type-safely solve these issues, we adopt **[Effect](https://effect.website/) (effect-ts)**, a powerful functional effect system for TypeScript, as the foundation for the application and infrastructure layers.

### Specific Design and Usage Policies

#### 1. Declarative and Type-Safe Error Handling

All operations are represented by the `Effect<Success, Error, Requirements>` type. By attaching a `_tag` to custom error classes (such as `ElevationFetchError` or `WasmError`), the compiler can infer and check where and what kinds of errors might occur, forcing exhaustive error handling through methods like `catchAll`.

#### 2. Reliable Wasm Resource Management via `Effect.acquireUseRelease`

The instantiation and release of the Wasm engine are wrapped in the `Effect.acquireUseRelease` pattern. This ensures that `engine.free()` is always executed even if an unexpected exception occurs during intermediate processing (such as PNG decoding or network communication), structurally preventing memory leaks in the edge environment.

```typescript
// Example implementation
Effect.acquireUseRelease(
  Effect.sync(() => new ShadowEngine()), // Acquire
  (engine) => Effect.gen(function* (_) { /* Processing using Wasm (Use) */ }),
  (engine) => Effect.sync(() => engine.free()) // Release
)

```

#### 3. Dependency Injection using Context

We avoid massive class-based DI container frameworks (like InversifyJS). Instead, we use Effect's `Context.GenericTag` and `Effect.provideService` to inject dependencies like `Logger` and `ElevationRepository` in a type-safe manner. This completely decouples Cloudflare Workers-specific implementations from the use cases (`CalculateShadowUseCase`).

#### 4. Ensuring Readability with `Effect.gen`

To avoid the deep method chains (`pipe`) typical of functional programming, we actively use the generator syntax (`Effect.gen` and `yield* _()`) to maintain intuitive readability similar to conventional `async / await`.

## Consequences

### Positive (Benefits)

#### **Prevention of Unexpected Panics**: Because errors are visualized as types, we can safely handle external API failures or decoding errors, and map them to appropriate HTTP status codes (like 502 or 500) at the caller router layer.

#### **Eradication of Memory Leaks**: Resources that require manual memory management, like Wasm, could be safely integrated using Effect's features.
- **Realization of Clean Architecture**: Since a design depending on interfaces (`Context`) is naturally enforced, mocking during testing (`provideService`) became extremely easy.
- **Optimization of Concurrent Processing**: Utilizing `Effect.all(..., { concurrency: 'unbounded' })` and similar features allowed us to concisely and safely write concurrent processing for fetching and decoding multiple tile images.

### Negative / Trade-offs

#### **High Learning Curve**: There is a learning curve for the development team to understand Effect concepts (generator syntax, Context, error channels, `pipe`, etc.) and the basics of functional programming.

#### **Increased Bundle Size**: Since Effect is a feature-rich library, the resulting Workers bundle size increases compared to writing in plain TypeScript (however, it is well within Cloudflare Workers' limits and poses no practical problems).

## Alternatives Considered

| Option | Evaluation | Reason for Rejection / Adoption |
| --- | --- | --- |
| **Native `Promise` + `try/catch**` | Rejected | Learning curve is zero and bundle size is minimal, but lacks error type safety (always `unknown`). Rejected because it lacks robustness; the risk of Wasm memory leaks (forgetting to write `finally`) cannot be eliminated. |
| **Class-based DI (InversifyJS / tsyringe)** | Rejected | Rejected because it introduces too much boilerplate in a stateless, lightweight execution environment like serverless functions, and reliance on decorators (`reflect-metadata`) negatively impacts bundle size and performance. |
| **`fp-ts` / `neverthrow` (Result type only)** | Rejected | Can achieve error type safety, but lacks strong features for DI, resource management, and concurrent processing. Adoption was skipped because Effect is a modern, next-generation library that solves all these issues comprehensively. |