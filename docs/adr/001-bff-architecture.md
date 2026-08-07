# ADR 001: Adoption of BFF (Backend For Frontend) Architecture

## Background and Challenges

The core functionality of YAMAKAGE is to "analyze terrain data within a 20km radius from the current location, compare it with the sun's trajectory, and calculate the true sunset and sunrise times."
During the initial conceptual phase, it was necessary to decide whether to execute this calculation on the client side (Garmin devices) or on the server side.

Garmin devices (especially Data Field apps) have the following severe constraints:

1. **Memory Limits**: The memory limit for Data Field apps on many devices is restricted to 32KB.
2. **CPU and Battery Constraints**: Downloading massive amounts of elevation tile images (PNG), decoding RGB values per pixel into elevation, and performing trajectory calculations using trigonometric functions for hundreds of sampling points heavily consumes the CPU of wearable devices and rapidly depletes the battery.

## Decision

We adopt a design that delegates all complex terrain data retrieval, parsing, and sunset calculation logic to a **BFF built on Cloudflare Workers**.

- **Garmin's Responsibilities**: Acquiring GPS coordinates (latitude and longitude) and sending them to the BFF. Rendering only the minimal calculation results (minutes and UNIX time) received from the BFF on the screen.
- **BFF's Responsibilities**: Collecting terrain data from external APIs, PNG decoding, calculating elevation for each sampling point, and determining intersection with the sun's trajectory using SunCalc. Payload optimization for Garmin devices (extremely small arrays to clear the 32KB limit) and the Web.

## Consequences and Impact

### Pros

- **Overcoming Hardware Constraints**: Successfully cleared the severe memory and CPU limitations of Garmin devices.
- **Minimizing Battery Consumption**: Because heavy computations are performed on the cloud side, it does not significantly impact the device's battery even during prolonged use.
- **Standardization of Business Logic**: The calculation logic (e.g., `CalculateShadowUseCase`) can now be completely reused in the web version (`yamakage-site`).

### Cons and Trade-offs

- **Mandatory Online Environment**: Since computations go through the BFF, the smartphone must be connected via Bluetooth and within mobile network coverage during the activity. The latest calculation results cannot be received in areas without a signal.
