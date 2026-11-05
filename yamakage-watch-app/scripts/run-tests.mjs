import { spawn } from 'node:child_process';
import path from 'node:path';
import fs from 'node:fs/promises';
import iconv from 'iconv-lite'

const pipeAsync = (...fns) => (x) => fns.reduce(async (v, f) => f(await v), x);

// ==================================================
// Load arguments and environment variables
// ==================================================
const loadConfig = (ctx) => {
  const sdk = ctx.env.GARMIN_SDK_BIN?.trim();
  const key = ctx.env.GARMIN_KEY_PATH?.trim();
  const singleDevice = ctx.env.GARMIN_DEVICE?.trim();
  
  const isAllDevices = ctx.args.includes('--all');

  if (!sdk || !key) {
    throw new Error("Environment variables 'GARMIN_SDK_BIN' or 'GARMIN_KEY_PATH' are not set.");
  }
  if (!isAllDevices && !singleDevice) {
    throw new Error("Environment variable 'GARMIN_DEVICE' is not set. Please set a single device or run with '--all'.");
  }

  return { ...ctx, config: { sdk, key, singleDevice, isAllDevices } };
};

// ==================================================
// Generate paths
// ==================================================
const createPaths = (ctx) => {
  const { sdk } = ctx.config;
  const paths = {
    manifest: path.normalize('manifest.xml'),
    monkeyc: path.join(sdk, 'monkeyc'),
    monkeydo: path.join(sdk, 'monkeydo'),
    outDir: path.normalize('bin')
  };
  return { ...ctx, paths };
};

// ==================================================
// Determine target devices based on flags
// ==================================================
const determineDevices = async (ctx) => {
  if (!ctx.config.isAllDevices) {
    console.log(`Target device: ${ctx.config.singleDevice} (from .env)`);
    return { ...ctx, config: { ...ctx.config, devices: [ctx.config.singleDevice] } };
  }

  console.log('Parsing manifest.xml to retrieve all devices...');
  const xmlContent = await fs.readFile(ctx.paths.manifest, 'utf-8');
  const regex = /<iq:product\s+id="([^"]+)"/g;
  const devices = [];
  let match;
  
  while ((match = regex.exec(xmlContent)) !== null) {
    devices.push(match[1]);
  }

  if (devices.length === 0) {
    throw new Error("No devices specified in manifest.xml.");
  }

  console.log(`Target devices for testing (${devices.length}): ${devices.join(', ')}`);
  return { ...ctx, config: { ...ctx.config, devices } };
};

// ==================================================
// Execution function
// ==================================================
const execCommand = (cmd, isTest = false) => {
return new Promise((resolve, reject) => {
    const proc = spawn(cmd, { shell: true });
    let output = '';

    const handleData = (data) => {
      const decodedText = process.platform === 'win32' 
        ? iconv.decode(data, 'Shift_JIS') 
        : data.toString();

      process.stdout.write(decodedText);
      output += decodedText;
    };

    proc.stdout.on('data', handleData);
    proc.stderr.on('data', handleData);
    
    proc.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`Command failed with exit code: ${code}\nCommand: ${cmd}`));
        return;
      }

      if (isTest && (output.includes('FAILED (') || output.includes('Status:\nFAIL'))) {
        reject(new Error(`Test failed:: ${cmd}`));
        return;
      }

      resolve();
    });
  });
};

// ==================================================
// Build all devices
// ==================================================
const buildAllDevices = async (ctx) => {
  console.log('Starting build...');
  const { config: { devices, key }, paths: { monkeyc, outDir } } = ctx;
  const builtArtifacts = [];

  for (const device of devices) {
    const prgPath = path.join(outDir, `Yamakage-test-${device}.prg`);
    const cmd = `"${monkeyc}" -d ${device} -y "${key}" -f monkey.jungle -o "${prgPath}" -t`;

    console.log(`\n========================================`);
    console.log(`[${device}] Running build...`);
    console.log(`========================================`);
    
    await execCommand(cmd);
    
    console.log(`[${device}] ✅ Build complete!`);
    builtArtifacts.push({ device, prgPath });
  }

  return { ...ctx, builtArtifacts };
};

// ==================================================
// Execute tests
// ==================================================
const executeTests = async (ctx) => {
  const { platform, paths: { monkeydo }, builtArtifacts } = ctx;
  const testFlag = platform === 'win32' ? '/t' : '-t';

  for (const { device, prgPath } of builtArtifacts) {
    console.log(`\n▶️ Running test: ${device}...`);
    const cmd = `"${monkeydo}" "${prgPath}" ${device} ${testFlag}`;
    
    await execCommand(cmd, true);
    
    console.log(`[${device}] ✅ Test successful!`);
  }
  return ctx;
};

// ==================================================
// Orchestration
// ==================================================
const main = async () => {
  try {
    const runAsyncPipeline = pipeAsync(
      loadConfig,
      createPaths,
      determineDevices,
      buildAllDevices,
      executeTests
    );

    await runAsyncPipeline({
      env: process.env,
      platform: process.platform,
      args: process.argv.slice(2)
    });

    console.log('All tests completed successfully!');
  } catch (error) {
    console.error(`❌ ${error instanceof Error ? error.message : error}`);
    process.exit(1);
  }
};

main();