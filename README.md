# YAMAKAGE (山影)

YAMAKAGE is an application system that combines topographical data around a user's current or specified location with the sun's trajectory to calculate and simulate the **"true sunset and sunrise times"** hidden behind mountains or surrounding obstacles.

During mountain climbing and outdoor activities, it accurately predicts the "actual darkness" that arrives earlier than the standard sunset time, supporting safer activity planning.

## 📦 Repository Structure (Monorepo)

This repository is structured as a monorepo containing the backend API, the Web app frontend, and Garmin smartwatch apps (Data Field version and Standalone Watch App version).

```text
.
├── backend/                # Backend API (BFF) & Core Calculation Engine
│   ├── yamakage/           # 🌐 Cloudflare Workers API (TypeScript / Hono)
│   └── yamakage-wasm/      # ⚙️ Core Calculation Engine (Rust / WebAssembly)
├── web-site/               # 💻 Web Frontend (React / TypeScript / Vite)
├── yamakage-datafield/     # ⌚️ Garmin Connect IQ App (Data Field version / Monkey C)
├── yamakage-watch-app/     # ⌚️ Garmin Connect IQ App (Standalone Watch App version / Monkey C)
├── yamakage-datafield/devtools/icon_generater/
│                           # 🔧 Tool to convert SVG icons into font files usable on Garmin devices
└── docs/                   # 📄 Architecture Documents and ADRs

```

## 🚀 Roles by Project

### 1. Backend API (`backend/`)

A BFF (Backend For Frontends) running on Cloudflare Workers.
To overcome CPU and memory constraints in edge environments, it adopts a **zero-copy hybrid architecture using TypeScript and Rust (Wasm)**.

#### **`backend/yamakage/` (TypeScript / Hono / Effect):**

Handles network I/O and routing. It receives requests from Garmin devices and the Web, fetches terrain tiles (PNGs) from AWS Open Data, and manages cache processing with Cloudflare R2.

#### **`backend/yamakage-wasm/` (Rust / WebAssembly):**

Handles pure, high-load calculation logic (image decoding, elevation extraction, terrain profile construction, and sun trajectory simulation). It processes PNG binaries streamed directly into memory from the TS layer and returns the results as a flat array back to the TS layer.

### 2. Web Application (`web-site/`)

A web simulation application running in the browser (hosted on Cloudflare Pages).
Users can specify any point on a map to visually check the surrounding terrain profile (maximum elevation angle in each direction) and the sun's trajectory graph.

- **Stack:** React, TypeScript, Vite
- **Features:** Simulation of any location by clicking on the map, graphical display of results (Skyline Chart), SNS sharing functionality, etc.

### 3. Garmin Data Field App (`yamakage-datafield/`)

A Connect IQ Data Field app for Garmin smartwatches.
Integrated into activity screens during hikes or runs, it displays the true sunset time of the current location in real-time.

- **Stack:** Monkey C
- **Features:** Background GPS location tracking, periodic API communication, and UI rendering and data processing optimized for ultra-low memory environments.
> *Note: By offloading all heavy calculation processes to the backend API, it minimizes device battery consumption.*



### 4. Garmin Watch App (`yamakage-watch-app/`)

A Connect IQ Watch App (standalone app) for Garmin smartwatches.
It can be launched on-demand at any time, even outside of activities, allowing users to visually grasp the surrounding terrain and sunlight conditions with rich graphics.

- **Stack:** Monkey C
- **Features:** On-demand GPS acquisition and API communication triggered by button presses. Features advanced graphic rendering, including a "Panorama View" that draws mountain silhouettes in the direction the user is facing, and a "SkyPlot," offering a 360-degree bird's-eye view of the terrain and the sun's trajectory.

### 5. Documentation (`docs/`)

Contains system architecture diagrams and records of architectural design decisions.

## 📖 Development Setup

Navigate to each project's directory and refer to their respective `README.md` files.

---

## Repository Root Commands

- `pnpm install`: Installs dependencies for all Node-based projects across the entire repository.
- `pnpm clean`: Removes auto-generated folders (such as `node_modules`) across the entire repository.