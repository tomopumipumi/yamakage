# Domain Architecture Diagram

## 1. Backend Calculation Algorithm (TypeScript + WebAssembly)

```mermaid
flowchart TD
    classDef wasm fill:#e0e7ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    classDef ts fill:#fef08a,stroke:#c2165b,stroke-width:2px,color:#831843
    classDef data fill:#f3f4f6,color:#000,stroke:#6b7280,stroke-width:1px,stroke-dasharray: 5 5
    classDef external fill:#fce7f3,stroke:#db2777,stroke-width:2px,color:#be185d

    Start((Calculation Start<br/>Lat, Lng, Time))

    subgraph Phase1 [1. Spatial Sampling]
        TSE[generate_sampling_points<br/>Wasm / Rust]:::wasm
        Note1(Starts from 100m away to prevent near-field noise.<br/>Generates radially up to 30km depending on Quality setting.)
        TPE_MEM[(Wasm Memory)]:::data
        TSE -.- Note1
    end

    subgraph Phase2 [2. Elevation Data Fetch & Wasm Decode]
        UseCase[CalculateShadowUseCase<br/>TypeScript]:::ts
        Repo[TileElevationRepository<br/>Fetch image from R2 / AWS]:::external
        DECODE[decode_tile_elevations<br/>Wasm / Rust]:::wasm
        Note2(TS fetches uncompressed PNG binaries and injects them directly into Wasm.<br/>Rust rapidly decodes them, extracts and saves elevation values.)
        UseCase -.- Note2
    end

    subgraph Phase3 [3. Terrain Profile Construction]
        TPE[calculate_azimuth_profiles<br/>Wasm / Rust]:::wasm
        Note3(Calculates the 'maximum obstacle elevation angle' for each azimuth,<br/>accounting for Earth's curvature and atmospheric refraction.)
        TPE -.- Note3
    end

    subgraph Phase4 [4. Sun Trajectory & Mountain Shadow Intersection Simulation]
        SCE[simulate_sun_path<br/>Wasm / Rust]:::wasm
        SPE[get_sun_position<br/>Wasm / Rust]:::wasm
        Note4(Advances time minute by minute from past 12 hrs to future 48 hrs,<br/>detecting the inversion timing of the sun's upper limb altitude and terrain elevation angle.)
        
        SCE --> |Minute-by-minute time| SPE
        SPE --> |Solar azimuth / altitude| SCE
        SCE -.- Note4
    end

    End((True Sunset/Sunrise Time<br/>+ Elevation of current location & highest point))

    Start --> |Start Lat/Lng| TSE
    TSE --> |Panorama coordinate list| TPE_MEM
    TPE_MEM --> |Read Lats/Lngs pointers| UseCase
    UseCase --> |Coordinate list| Repo
    Repo --> |Raw PNG binary| UseCase
    UseCase --> |Inject PNG binaries and coordinate indices| TPE_MEM
    
    TPE_MEM --> DECODE
    DECODE --> |Extracted elevation values| TPE_MEM
    
    TPE_MEM --> |Lat/Lng/Elevation| TPE
    TPE --> |AzimuthProfiles<br/>Max elevation angle per azimuth| SCE
    Start --> |Lat, Lng, Time| SCE
    
    SCE --> |Flat array pointer<br/>Complete zero-copy read| End

```

### TypeScript and Wasm Architecture

While computational processes that act as performance bottlenecks are handled by Rust (Wasm), fetching elevation tiles that require asynchronous I/O communication is handled on the TypeScript side.
The most significant feature is the complete zero-copy design, which entirely avoids heavy image extraction and JSON serialization on the JS side. By pouring uncompressed PNG binaries fetched on the TS side directly into the Wasm memory space and letting Rust handle the image decoding and elevation extraction, memory bloat (GC spikes) on the JS side is completely eliminated. Furthermore, reading the output results via a pointer to a flat 1D array achieves faster response times and conserves container resources.

### Sampling Interval Optimization

To reduce computational load while increasing near-field accuracy and preventing false detection of noise right at the user's feet, the sampling interval is dynamically changed based on the distance (for Quality 2 settings).

- 100 to 2000m: 30m intervals
- 2.1km to 10km: 90m intervals
- 10.2km to 30km: 200m intervals

### Consideration of Earth's Curvature and Atmospheric Refraction (TerrainProfileEngine)

Because distant mountains appear to sink below the horizon due to the roundness of the Earth, the apparent drop in elevation is corrected using `(Distance^2 / 2R) * 0.86` (where 0.86 is a coefficient accounting for atmospheric refraction, etc.) rather than simple elevation differences. Additionally, to accurately simulate the user's field of view, `1.5m` (eye level) is added to the elevation of the current location before calculating the elevation angle.

### Minute-by-Minute Simulation (ShadowCalculationEngine)

Because it is difficult to find the exact intersection point in a single mathematical formula, a simulation approach is adopted that advances time minute by minute from **12 hours in the past to 48 hours in the future (-720 to 2880 minutes)** relative to the specified time. The solar position is calculated for each minute, the terrain profile (maximum elevation angle per azimuth) is linearly interpolated, and the exact moment the sun's altitude drops below or rises above the terrain elevation angle is determined as sunset or sunrise. Furthermore, by factoring in the sun's apparent angular radius (approximately 0.266 degrees), the exact moment the upper limb of the sun hides or emerges is accurately detected.