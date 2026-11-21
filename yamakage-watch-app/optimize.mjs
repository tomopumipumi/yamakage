import { buildOptimizedProject, getConfig } from "@markw65/monkeyc-optimizer";
import { optimizeProgram } from "@markw65/monkeyc-optimizer/sdk-util.js";
import * as path from "node:path";

// ==================================================
// Minimal Result & Utility Helpers
// ==================================================
const ok = (value) => ({ ok: true, value });
const err = (error) => ({ ok: false, error });

// Execute a side effect without altering the piped value
const tap = (fn) => (value) => {
  fn(value);
  return value;
};

// ==================================================
// Functional Core (Pure Functions)
// ==================================================
const parseBuildContext = (argv, env, cwd) => {
  const isExport = argv.includes("--export");
  const jungleArgs = argv.filter((arg) => arg !== "--export");

  if (jungleArgs.length === 0) {
    return err("No jungle files specified.");
  }

  // Pass null as the target device to trigger an .iq export build
  const targetDevice = isExport ? null : env.GARMIN_DEVICE?.trim() || null;
  if (!isExport && targetDevice === null) {
    return err("Environment variable 'GARMIN_DEVICE' is not set.");
  }

  const resolvedJungles = jungleArgs.map((file) => path.resolve(cwd, file));

  return ok({
    targetDevice,
    workspace: path.dirname(resolvedJungles[0]),
    jungleFiles: resolvedJungles.join(";"),
  });
};

const toConfigOptions = ({ workspace, jungleFiles }) => ({
  workspace,
  buildDir: "bin",
  outputPath: "bin/optimized",
  jungleFiles,
  returnCommand: false,
  releaseBuild: true,
});

// ==================================================
// Async Pipeline
// ==================================================
const runBuildPipeline = (context, onLog = console.log) =>
  getConfig(toConfigOptions(context)).then((options) =>
    buildOptimizedProject(context.targetDevice, options)
      .then(tap(({ program }) => onLog(`Built: ${program}`)))
      .then(({ program }) =>
        optimizeProgram(program, options.developerKeyPath, undefined, options)
      )
      .then(tap(({ output }) => onLog(`Optimized: ${output}`)))
  );

// ==================================================
// Imperative Shell (Entry Point)
// ==================================================
const main = async (argv, env, cwd) => {
  const contextResult = parseBuildContext(argv, env, cwd);

  if (!contextResult.ok) {
    console.error(`[Config Error] ${contextResult.error}`);
    process.exit(1);
  }

  return runBuildPipeline(contextResult.value).catch((error) => {
    console.error("\n[Build Error] An error occurred during the build:", error);
    process.exit(1);
  });
};

main(process.argv.slice(2), process.env, process.cwd());