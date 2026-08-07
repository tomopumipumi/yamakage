# Domain Architecture Diagram

```mermaid
flowchart TD
    classDef engine fill:#e0e7ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    classDef data fill:#f3f4f6,stroke:#6b7280,stroke-width:1px,stroke-dasharray: 5 5
    classDef external fill:#fce7f3,stroke:#db2777,stroke-width:2px,color:#be185d

    Start((Calculation Start<br/>Lat, Lng, Time))

    subgraph Phase1 [1. Spatial Sampling]
        TSE[TerrainSamplingEngine]:::engine
        Note1(Fine near, coarse far<br/>Generates sampling coordinates radially<br/>at 15-degree intervals up to 20km)
        TSE -.- Note1
    end

    Repo[ElevationRepository<br/>Fetch Elevation Data]:::external

    subgraph Phase2 [2. Terrain Profile Construction]
        TPE[TerrainProfileEngine]:::engine
        Note2(Calculates the 'max obstacle elevation angle'<br/>for each azimuth,<br/>considering Earth's curvature)
        TPE -.- Note2
    end

    subgraph Phase3 [3. Simulation of Sun Path & Mountain Shadow Intersection]
        SCE[ShadowCalculationEngine]:::engine
        SPE[SunPositionEngine]:::engine
        Note3(Advances time minute by minute<br/>to detect the moment the sun's altitude<br/>and interpolated terrain elevation angle invert)
        
        SCE --> |Minute-by-minute Time| SPE
        SPE --> |Sun Azimuth & Altitude| SCE
        SCE -.- Note3
    end

    End((True Sunset/Sunrise Time))

    Start --> |Start Lat/Lng| TSE
    TSE --> |Panorama<br/>Coordinate List| Repo
    
    TSE --> |Panorama<br/>Coordinate List| TPE
    Repo --> |ElevationsMap<br/>Elevation Map| TPE
    
    TPE --> |AzimuthProfiles<br/>Max Elevation Angle per Azimuth| SCE
    Start --> |Lat, Lng, Time| SCE
    
    SCE --> End

```

### Optimization of Sampling Intervals (TerrainSamplingEngine)

To increase the accuracy of the near-field view while keeping computational costs low, the sampling intervals are dynamically adjusted based on distance.

- **0–500m:** 100m intervals
- **500m–2km:** 300m intervals
- **2km–10km:** 2,000m intervals
- **10km–20km:** 5,000m intervals

### Consideration of Earth's Curvature and Atmospheric Refraction (TerrainProfileEngine)

Because distant mountains appear lower due to the roundness of the Earth, the elevation angle is calculated after correcting for the apparent drop in elevation. Instead of using a simple elevation difference, we use the formula `(Distance^2 / 2R) * 0.86` (where 0.86 is a coefficient accounting for atmospheric refraction, etc.) to apply this correction.

### Minute-by-Minute Simulation (ShadowCalculationEngine)

Since it is difficult to calculate the exact intersection point using a single mathematical formula, we adopted a simulation approach that advances the time minute by minute, up to 48 hours (2,880 minutes) ahead of the specified time.

For each minute, the solar position is calculated using the `SunPositionEngine` (a SunCalc wrapper). The terrain profile (sampled at 15-degree intervals) is then linearly interpolated (`getInterpolatedObstacleAngle`), and the exact moment the sun's altitude drops below (or rises above) the terrain's elevation angle is identified as the result.