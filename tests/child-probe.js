const assert = require('node:assert/strict');
const fs = require('node:fs');
const pathModule = require('node:path');
const { execFileSync } = require('node:child_process');

const direct = (name) => execFileSync('/usr/bin/which', [name], { encoding: 'utf8' }).trim();
const cleanBin = process.env.PATH.split(':').find((part) =>
  part === '/opt/homebrew/bin' || part === '/usr/local/bin');
assert.ok(cleanBin, 'clean Homebrew bin missing from child PATH');
for (const name of ['node', 'npm', 'npx']) {
  const path = direct(name);
  assert.equal(path, `${cleanBin}/${name}`);
  assert.equal(fs.realpathSync(path).includes('.devbar'), false);
}
assert.equal(process.execPath, fs.realpathSync(`${cleanBin}/node`));
assert.equal(process.env.PATH.includes('.devbar'), false);
assert.equal(process.env.PATH.includes('.local/bin'), false);
assert.equal(process.env.NODE_EXTRA_CA_CERTS, undefined);
assert.equal(process.env.NODE_OPTIONS, undefined);
assert.equal(process.env.HTTPS_PROXY, undefined);
assert.equal(process.env.AGENT_NOTIFY_WEBHOOK_URL, undefined);
assert.equal(process.env.PURE_TEST_INHERITED_MARKER, undefined);
assert.equal(pathModule.basename(process.env.HOME).startsWith('pure-'), true);
assert.equal(process.env.NPM_CONFIG_USERCONFIG.startsWith(process.env.HOME), true);
assert.equal(process.env.NPM_CONFIG_GLOBALCONFIG.startsWith(process.env.HOME), true);
assert.equal(execFileSync('npm', ['--version'], { encoding: 'utf8' }).trim(),
             execFileSync(`${cleanBin}/npm`, ['--version'], { encoding: 'utf8' }).trim());
assert.equal(execFileSync('npx', ['--version'], { encoding: 'utf8' }).trim(),
             execFileSync(`${cleanBin}/npx`, ['--version'], { encoding: 'utf8' }).trim());
console.log('child npm/npx/node and environment are clean');
