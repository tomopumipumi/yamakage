# YAMAKAGE (Garmin Connect IQ App)

## Overview

A Watch App(Device App) for Garmin devices (Edge, Fenix, Forerunner, etc.) that displays the "true sunrise and sunset times" by taking the surrounding terrain (elevation) into account.

It communicates with a dedicated backend server (YAMAKAGE API) to calculate the height of surrounding mountains and obstacles from your current location, predicting accurate daylight hours.

---

## Preparation (Garmin SDK Setup)

Before starting development, you need to prepare the official Garmin Connect IQ development environment.

### 1. Installing Connect IQ SDK Manager

Download and install the "Connect IQ SDK Manager" from the Garmin [developer site](https://developer.garmin.com/connect-iq/overview/), and download the latest SDK.

### 2. Creating a Developer Key

Create a private key (`.der` file) to build and sign the app.
Open a terminal and use the `monkeyc` command located in the SDK's `bin` directory to generate the key.

```sh
# Example key generation command (replace the path with your environment's bin path)
/path/to/connectiq-sdk/bin/monkeyc -a developer_key.der

```

Place the generated `developer_key.der` in the project's root directory (Note: It will not be committed to Git as it is excluded via `.gitignore`).

---

## Environment Setup

### 1. Installing `pnpm`

We use `pnpm` as the package manager and script runner.

```sh
npm install -g pnpm

```

### 2. Installing Dependencies

Run the following command in the directory containing `package.json` to install development tools such as the code formatter (Prettier).

```sh
pnpm install

```

### 3. Setting Up Environment Variables

Copy `.env.example` in the project root to create `.env`, and configure the necessary environment variables for your setup.

```sh
cp .env.example .env

```

Please enter the following variables in the `.env` file according to your environment.

| Variable Name | Description | Example (Windows) | Example (Mac) |
| --- | --- | --- | --- |
| `GARMIN_DEVICE` | The target device ID to launch and test in the simulator. | `edge1040` | `edge1040` |
| `GARMIN_KEY_PATH` | Absolute (or relative) path to the created developer key. | `C:\keys\developer_key.der` | `/Users/name/keys/developer_key.der` |
| `GARMIN_SDK_BIN` | Absolute path to the `bin` folder of the downloaded Garmin SDK. | `C:\Users\name\AppData\Roaming\Garmin\ConnectIQ\Sdks\connectiq-X.Y.Z\bin` | `/Users/name/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-X.Y.Z/bin` |

---

## Local Execution & Development

### 1. Launching the Simulator

Running the following command will automatically build the code and launch the simulator for the configured `GARMIN_DEVICE`.

```sh
pnpm run dev

```

---

## Commands

| Command | Description |
| --- | --- |
| `pnpm run dev` | Executes a debug build and launches the simulator. |
| `pnpm run dev:release` | Launches the simulator with a release build (optimized). |
| `pnpm run test` | Builds unit tests and executes them on the simulator. |
| `pnpm run fmt` | Formats the code using Prettier (monkeyc plugin). |
| `pnpm run export` | Exports the `.iq` file for submission to the Connect IQ Store. |

---

## Creating the Store Release File

Follow these steps to generate the `.iq` file required for submitting the app to the Connect IQ Store.
Run the following command:

```sh
pnpm run export

```

Once the process is complete, a file named `yamakage-watch-app.iq` will be generated inside the project's `bin` directory.

Uploading this file via the [Garmin Developer Dashboard](https://www.google.com/search?q=https://developer.garmin.com/connect-iq/overview/) will complete your application for store release.

---

## License

This project is licensed under the [MIT License](https://www.google.com/search?q=./LICENSE).