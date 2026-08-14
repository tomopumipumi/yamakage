# System Architecture Document

This document defines the overall system architecture and provides an overview of the data flow for the YAMAKAGE application and its backend API (BFF).

## Overall System Architecture

The diagram below illustrates the complete system flow, connecting the clients (Garmin devices / Web) to the backend and external services (AWS Open Data).

```mermaid
flowchart TB
    classDef client fill:#191970,stroke:#28a745,stroke-width:2px,color:#fff;
    classDef cloudflare fill:#fff3cd,color:#000,stroke:#ffc107,stroke-width:2px;
    classDef wasm fill:#e0e7ff,color:#1e3a8a,stroke:#2563eb,stroke-width:2px;
    classDef external fill:#5f9ea0,color:#fff,stroke:#6c757d,stroke-width:2px;
    classDef database fill:#cce5ff,color:#000,stroke:#004085,stroke-width:2px;

    subgraph Clients ["Client Layer"]
        Garmin["Garmin Device\n(Connect IQ App)"]:::client
        Web["Web Application\n(yamakage-site)"]:::client
    end

    subgraph Cloudflare ["Cloudflare (Backend Layer)"]
        Turnstile{"Turnstile<br/>(Bot Verification)"}:::cloudflare
        RateLimiter{"Rate Limiter"}:::cloudflare
        
        subgraph API_Layer ["YAMAKAGE API (Workers)"]
            API["TypeScript / Hono<br/>(Routing & I/O Control)"]:::cloudflare
            WASM["WebAssembly / Rust<br/>(ShadowEngine)"]:::wasm
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
    Pages -- "Serve HTML" --> Web

    API -- "1. Check Cache" --> R2
    R2 -- "2a. Hit (PNG)" --> API
    API -- "2b. Miss" --> AWS
    AWS -- "3. Fetch Tile (PNG)" --> API
    API -. "4. Async Cache Storage<br/>(waitUntil)" .-> R2

    API -- "5. Inject Elevation to Memory<br/>& Execute Calculation" --> WASM
    WASM -- "6. Return Calculation Result" --> API
    
    API -- "7. Return Result (JSON)" --> Garmin
    API -- "7. Return Result (JSON)" --> Web

```

## Component Details

### 1. Client Layer

**Garmin Device (`yamakage/source/`)**

* A Connect IQ data field app implemented in Monkey C.
* It sends latitude and longitude acquired via GPS to the API using a background process (at a minimum interval of 5 minutes).
* API authentication uses a Bearer token with the `YAMAKAGE_API_KEY`.

**Web Application (`yamakage-site`)**

* A client providing features tailored for web browsers.
* Serves static files via `Cloudflare Pages`.
* To prevent unauthorized access and bot requests, it attaches a `Cloudflare Turnstile` token to outgoing requests.

---

### 2. Backend Layer (Cloudflare Workers)

**YAMAKAGE API (`yamakage/backend/yamakage/`)**

* A `BFF (Backend For Frontends)` built with `Cloudflare Workers + Hono`.
* **Hybrid Architecture**:
* The **TypeScript (Effect)** side handles I/O operations (request routing, fetching and decoding PNG tiles).
* The **WebAssembly (Rust)** side (`ShadowEngine`) handles the pure, highly-intensive computational logic.


* Large amounts of elevation data fetched on the TypeScript side are directly written into the Wasm memory space. Wasm then executes a high-speed, in-memory simulation combining the sun's trajectory with terrain profiles.
* To preserve the Garmin device's processing power and battery life, all heavy computational workloads are completely offloaded to the backend.

**Rate Limiter / Turnstile**

* To prevent API overload and DDoS attacks, requests are restricted (Rate Limited) per session ID or IP address. Access from web clients goes through bot verification using `Turnstile`.

**Cloudflare R2**

* An object storage service used to cache elevation tile images (PNG) fetched from AWS.
* It significantly reduces the number of requests made to the external API and drastically improves response speeds.

---

### 3. External Services

**AWS Open Data ([s3.amazonaws.com/elevation-tiles-prod/](https://s3.amazonaws.com/elevation-tiles-prod/))**

* Publicly provided worldwide terrain elevation data (Terrarium format PNG tiles).
* The system only fetches data from here on a cache miss (when the requested area does not exist in R2).