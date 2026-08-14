# Domain Architecture Diagram

## 1. Backend Calculation Algorithm (TypeScript + WebAssembly)

```mermaid
flowchart TD
    classDef wasm fill:#e0e7ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    classDef ts fill:#fef08a,stroke:#c2165b,stroke-width:2px,color:#831843
    classDef data fill:#f3f4f6,color:#000,stroke:#6b7280,stroke-width:1px,stroke-dasharray: 5 5
    classDef external fill:#fce7f3,stroke:#db2777,stroke-width:2px,color:#be185d

    Start((Start Calculation<br/>Lat, Lng, Time))

    subgraph Phase1 [1. Spatial Sampling]
        TSE[generate_sampling_points<br/>Wasm / Rust]:::wasm
        Note1(Start from 100m away to prevent near-field noise.<br/>Generate radially up to 30km depending on Quality setting)
        TPE_MEM[(Wasm Memory)]:::data
        TSE -.- Note1
    end

    subgraph Phase2 [2. Elevation Data Fetch & Injection]
        UseCase[CalculateShadowUseCase<br/>TypeScript]:::ts
        Repo[TileElevationRepository<br/>Fetch Elevation Data]:::external
        Note2(Fetch and decode tiles corresponding to coordinates on the TS side,<br/>and write elevation values directly to the Wasm memory space)
        UseCase -.- Note2
    end

    subgraph Phase3 [3. Terrain Profile Construction]
        TPE[calculate_azimuth_profiles<br/>Wasm / Rust]:::wasm
        Note3(Calculate the 'maximum obstacle elevation angle' for each azimuth,<br/>accounting for Earth's curvature and atmospheric refraction)
        TPE -.- Note3
    end

    subgraph Phase4 [4. Sun Path & Mountain Shadow Intersection Simulation]
        SCE[simulate_sun_path<br/>Wasm / Rust]:::wasm
        SPE[get_sun_position<br/>Wasm / Rust]:::wasm
        Note4(Advance time minute-by-minute from past 12 hours to future 48 hours<br/>to detect the intersection timing of the sun's upper edge altitude and terrain elevation angle)
        
        SCE --> |Minute-by-minute time| SPE
        SPE --> |Sun azimuth/altitude| SCE
        SCE -.- Note4
    end

    End((True Sunset/Sunrise Times<br/>+ Current/Highest Point Elevations))

    Start --> |Start Lat/Lng| TSE
    TSE --> |Panorama Coordinate List| TPE_MEM
    TPE_MEM --> |Lats/Lngs| UseCase
    UseCase --> |Coordinate List| Repo
    Repo --> |ElevationsMap| UseCase
    UseCase --> |Inject Elevation Data| TPE_MEM
    
    TPE_MEM --> |Lat/Lng/Elevation| TPE
    TPE --> |AzimuthProfiles<br/>Max elevation angle per azimuth| SCE
    Start --> |Lat, Lng, Time| SCE
    
    SCE --> End


```

### TypeScript and Wasm Memory Sharing Architecture

While the performance-bottleneck computational processing has been migrated to Rust (Wasm), the TypeScript side is responsible for fetching elevation tiles, which requires asynchronous I/O communication. By writing the massive amount of elevation data fetched on the TypeScript side directly into the Wasm memory space, serialization/deserialization overhead is reduced to zero.

### Optimization of Sampling Intervals

To suppress computational load while increasing near-field accuracy and preventing false detection of immediate noise, the sampling interval is dynamically adjusted based on the distance (in the case of Quality 2).

* 100m - 2000m: 30m intervals
* 2.1km - 10km: 90m intervals
* 10.2km - 30km: 200m intervals

### Consideration of Earth's Curvature and Atmospheric Refraction (TerrainProfileEngine)

Since distant mountains appear to sink due to the Earth's curvature, the apparent drop in elevation is corrected using `(distance^2 / 2R) * 0.86` (*0.86 is the coefficient accounting for atmospheric refraction, etc.) instead of a simple elevation difference. Furthermore, to accurately simulate the user's field of view, the elevation angle is calculated after adding `1.5m` (eye level) to the current elevation.

### Minute-by-Minute Simulation (ShadowCalculationEngine)

Since it is difficult to analytically find the intersection point with a single equation, we adopted a simulation approach that advances time minute-by-minute from **12 hours in the past to 48 hours in the future (-720 to 2880 minutes)** from the specified time. For each minute, the sun's position is calculated, the terrain profile (maximum elevation angle for each azimuth) is linearly interpolated, and the exact moment the sun's altitude falls below or rises above the terrain elevation angle is determined as sunset or sunrise. Additionally, by accounting for the sun's angular radius (approx. 0.266 degrees), the exact moment the sun's upper edge hides or appears is accurately determined.