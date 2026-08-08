# YAMAKAGE API

## Overview

This is an API server (BFF) that calculates and provides the true sunrise and sunset times, taking mountain shadows into account, for the Garmin app.

It runs on `Cloudflare Workers`, utilizes public datasets from `AWS Open Data` to retrieve elevation data, and uses `Cloudflare R2` as a caching feature.

## Environment Setup

### 0. Installing `pnpm`

We use `pnpm` as our package manager. If you haven't installed it yet, please install it via `npm` or a similar tool.

```sh
npm install -g pnpm

```

If the version is displayed by running the following command, the installation was successful.

```sh
pnpm --version

```

### 1. Installing Dependencies

Run the following command in the directory containing `package.json`.

```sh
pnpm install

```

## Local Execution & Development

### 0. Setting Up Environment Variables

Copy `.dev.vars.example` to create `.dev.vars`, and configure the necessary environment variables.

```sh
cp .dev.vars.example .dev.vars

```

| Variable Name | Description |
| --- | --- |
| `YAMAKAGE_API_KEY` | The key used for API authentication (Bearer Token). Please set any arbitrary string. |
| `TURNSTILE_SECRET_KEY` | Secret key for Turnstile used to perform bot verification. Enter the key displayed in the Turnstile widget management dashboard. |

### 1. Bucket Setup

Create a Cloudflare R2 bucket by running the following command:

```sh
pnpm run r2:create

```

### 2. Launching the Development Server

Run the following command to start the local server:

```sh
pnpm run dev

```

*Note: If you want to open the API documentation (Swagger UI) in your browser at the same time, use the following command:*

```sh
pnpm run dev:ui

```

## Commands

| Command | Description |
| --- | --- |
| `pnpm run dev` | Starts the local development server. |
| `pnpm run dev:ui` | Starts the local development server and opens Swagger UI in the browser. |
| `pnpm run test` | Runs tests using Vitest. |
| `pnpm run fmt` | Formats the code using Biome. |
| `pnpm run lint` | Performs static code analysis (Linting) using Biome. |
| `pnpm run fix` | Automatically fixes Lint errors and formats the code using Biome. |

## Deployment to Production Environment

These are the steps for deploying to Cloudflare.

### 1. Setting Up the Secret Key

Register the sensitive information specified in `.dev.vars` into the Cloudflare production environment.
Run the following command and follow the interactive prompt to enter the value for `YAMAKAGE_API_KEY`.

```sh
pnpm run register:apikey

```

### 4. Deployment

Deploy to Cloudflare Workers using the following command:

```sh
pnpm run deploy

```