# ADR 002: Adoption of Cloudflare R2 Cache for Elevation Tile Data

## Background and Challenges

To calculate sunset times in the BFF, it is necessary to fetch and analyze elevation tile images ([s3.amazonaws.com/elevation-tiles-prod/terrarium/](https://s3.amazonaws.com/elevation-tiles-prod/terrarium/){z}/{x}/{y}.png) publicly available on AWS Open Data.

Each calculation requires fetching multiple tile images around the current location. However, sending requests directly to AWS S3 every time causes the following issues:

1. **Increased Latency**: HTTP requests to an external service (AWS) become a bottleneck, delaying the response to the Garmin device.
2. **Wasted Bandwidth**: Even though terrain data is practically "immutable," the same images are downloaded every time multiple users visit the same mountainous area or when the same user makes periodic updates.
3. **Availability Risk from External Dependencies**: In the rare event that AWS S3 goes down or hits a rate limit, the entire app would become dysfunctional.

## Decision

We will introduce a **caching layer using Cloudflare R2** in front of the elevation tile fetching process from AWS.

- When tile images are needed, a fetch request is first made to R2 (the `yamakage-terrain-tiles` bucket).
- If the data exists in R2, it is used immediately.
- If it does not exist, it is fetched from AWS and **saved to R2 in the background using Cloudflare Workers' asynchronous processing (`c.executionCtx.waitUntil`)** to avoid blocking the response.

## Consequences and Impact

### Pros

- **Improved Performance**: Upon an R2 cache hit, data is fetched within the same Cloudflare network, significantly reducing latency.
- **Protecting User Experience**: Asynchronous saving using `waitUntil` allows the calculation process to proceed without waiting for the "save to R2 completion," even on a cache miss.
- **Cost Efficiency**: Since R2 has zero egress (outbound data transfer) fees, infrastructure costs can be kept low even if access increases.

### Cons and Trade-offs

- **Increased Code Complexity**: It became necessary to write logic in `TileElevationRepository.ts` to handle the fallback between R2 and AWS, as well as managing the asynchronous functions passed to `waitUntil`.
- **Increased Storage Capacity**: Stored data (capacity) in R2 accumulates every time the app is run in a new location (considering the immutability of terrain data, we accept an operation without a TTL, treating it as an indefinite cache).