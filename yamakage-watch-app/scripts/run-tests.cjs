const { execSync } = require('child_process');
const path = require('path');

const sdk = process.env.GARMIN_SDK_BIN?.trim();
const device = process.env.GARMIN_DEVICE?.trim();
const key = process.env.GARMIN_KEY_PATH?.trim();

if (!sdk || !device || !key) {
  console.error("Error: Required environment variable (.env) is not set.");
  process.exit(1);
}

const monkeyc = path.normalize(`${sdk}/monkeyc`);
const monkeydo = path.normalize(`${sdk}/monkeydo`);
const prgPath = path.normalize('bin/Yamakage-test.prg');

try {
  console.log('🛠️ Building tests...');
  execSync(`"${monkeyc}" -d ${device} -y "${key}" -f monkey.jungle -o "${prgPath}" -t`, { stdio: 'inherit' });

  const isWin = process.platform === 'win32';
  const testFlag = isWin ? '/t' : '-t';

  const cmd = `"${monkeydo}" "${prgPath}" ${device} ${testFlag}`;
  console.log(`> Execution command: ${cmd}`);
  
  execSync(cmd, { stdio: 'inherit' });
  
  console.log('✅ Tests completed successfully');
} catch (error) {
  console.error('❌ An error occurred while running tests');
  process.exit(1);
}