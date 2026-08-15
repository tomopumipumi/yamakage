# System Architecture Diagram

This document defines the overall system architecture and provides an overview of the data flow for the YAMAKAGE app and the backend API (BFF).

## Overall System Diagram

The following diagram illustrates the overall system connections, from the clients (Garmin devices / Web) to the backend and external services (AWS Open Data).

```mermaid
flowchart TB
    classDef client fill:#191970,stroke:#28a745,stroke-width:2px;
    classDef cloudflare fill:#fff3cd,color:#000,stroke:#ffc107,stroke-width:2px;
    classDef wasm fill:#e0e7ff,color:#1e3a8a,stroke:#2563eb,stroke-width:2px;
    classDef external fill:#5f9ea0 ,color:#000,stroke:#6c757d,stroke-width:2px;
    classDef database fill:#cce5ff,color:#000,stroke:#004085,stroke-width:2px;

    subgraph Clients ["Client Layer"]
        Garmin["Garmin Device\n(Connect IQ App)"]:::client
        Web["Web Application\n(yamakage-site)"]:::client
    end

    subgraph Cloudflare ["Cloudflare (Backend Layer)"]
        Turnstile{"Turnstile<br/>(Bot Verification)"}:::cloudflare
        RateLimiter{"Rate Limiter<br/>(Traffic Limiting)"}:::cloudflare
        
        subgraph API_Layer ["YAMAKAGE API (Workers)"]
            API["TypeScript / Hono<br/>(Routing, Comm, I/O)"]:::cloudflare
            WASM["WebAssembly / Rust<br/>(ShadowEngine / Decoder)"]:::wasm
        end

        R2[("Cloudflare R2<br/>(Elevation Tile Cache)")]:::database
        Pages["yamakage-site<br/>(Pages)"]:::cloudflare
    end

    subgraph External ["External Services"]
        AWS[("AWS Open Data<br/>(Terrain Tiles)")]:::external
    end

    Garmin -- "Send Lat/Lng<br/>(Bearer Auth)" --> RateLimiter
    Web -- "Send Lat/Lng<br/>(Turnstile Token)" --> Turnstile
    Turnstile -- "Verification Success" --> RateLimiter
    RateLimiter -- "Request Passed" --> API
    Pages -- "HTML Delivery" --> Web

    API -- "1. Check Cache" --> R2
    R2 -- "2a. Hit (PNG Binary)" --> API
    API -- "2b. Miss" --> AWS
    AWS -- "3. Fetch Tile (PNG Binary)" --> API
    API -. "4. Save to cache asynchronously<br/>(waitUntil)" .-> R2

    API -- "5. Inject raw PNG binary to Wasm memory" --> WASM
    WASM -- "6. Return pointer to calculation result" --> API
    
    API -- "7. Return calculation result (JSON)" --> Garmin
    API -- "7. Return calculation result (JSON)" --> Web

```

## Component Details

### 1. Client Layer

**Garmin Device (`yamakage/source/`)**

- A Connect IQ data field app implemented in Monkey C.
- Sends latitude and longitude acquired from GPS to the API via background processing (at minimum 5-minute intervals).
- Uses Bearer token authentication with `YAMAKAGE_API_KEY` for API authentication.

**Web Application (`yamakage-site`)**

- A client that provides features for web browsers.
- Delivers static files via `Cloudflare Pages`.
- Attaches a `Cloudflare Turnstile` token to requests to prevent unauthorized access and bot requests.

### 2. Backend Layer (Cloudflare Workers)

**YAMAKAGE API (`yamakage/backend/yamakage/`)**

- A `BFF (Backends For Frontends)` built with `Cloudflare Workers + Hono`.
- **Complete Zero-Copy Hybrid Architecture**:
- The **TypeScript (Effect)** side is solely responsible for pure network I/O processing (request handling, fetching PNG tiles) and performs no heavy serialization or image decoding.
- The **WebAssembly (Rust)** side (`ShadowEngine`) handles all high-speed decoding of PNG images, extraction of elevation values, and pure, high-load in-memory simulations (determining the intersection of the solar trajectory and terrain).


- By pouring the uncompressed PNG binaries fetched on the TypeScript side directly into the Wasm shared memory space, memory bloat (garbage collection) on the JS side is prevented, drawing out extreme performance.
- To conserve the processing power and battery of the Garmin device, all these heavy computational processes are offloaded to the backend.

**Rate Limiter / Turnstile**

- To prevent API overload and DDoS attacks, the number of requests is restricted (Rate Limit) per session ID or IP address. Access from web clients is intercepted by `Turnstile` for bot verification.

**Cloudflare R2**

- Object storage that caches elevation tile images (PNG) fetched from AWS.
- Significantly reduces the number of requests to the external API and improves response speed.

### 3. External Services

**AWS Open Data ([s3.amazonaws.com/elevation-tiles-prod/](https://s3.amazonaws.com/elevation-tiles-prod/))**

- Publicly available global terrain elevation data (PNG tiles in Terrarium format).
- The system fetches from here only when an area that does not exist in the cache (R2) is requested.