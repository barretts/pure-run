const assert = require('node:assert/strict');
const fs = require('node:fs');
const { execFileSync } = require('node:child_process');

const direct = (name) => execFileSync('/usr/bin/which', [name], { encoding: 'utf8' }).trim();
for (const name of ['node', 'npm', 'npx']) {
  const path = direct(name);
  assert.equal(path, `/opt/homebrew/bin/${name}`);
  assert.equal(fs.realpathSync(path).includes('.devbar'), false);
}
assert.equal(process.execPath, fs.realpathSync('/opt/homebrew/bin/node'));
assert.equal(process.env.PATH.includes('.devbar'), false);
assert.equal(process.env.PATH.includes('.local/bin'), false);
assert.equal(process.env.NODE_EXTRA_CA_CERTS, undefined);
assert.equal(process.env.NODE_OPTIONS, undefined);
assert.equal(process.env.HTTPS_PROXY, undefined);
assert.equal(process.env.AGENT_NOTIFY_WEBHOOK_URL, undefined);
assert.equal(process.env.PURE_TEST_INHERITED_MARKER, undefined);
assert.equal(process.env.HOME.startsWith('/Users/bsonntag'), false);
assert.equal(process.env.NPM_CONFIG_USERCONFIG.startsWith(process.env.HOME), true);
assert.equal(process.env.NPM_CONFIG_GLOBALCONFIG.startsWith(process.env.HOME), true);
assert.equal(execFileSync('npm', ['--version'], { encoding: 'utf8' }).trim(),
             execFileSync('/opt/homebrew/bin/npm', ['--version'], { encoding: 'utf8' }).trim());
assert.equal(execFileSync('npx', ['--version'], { encoding: 'utf8' }).trim(),
             execFileSync('/opt/homebrew/bin/npx', ['--version'], { encoding: 'utf8' }).trim());
console.log('child npm/npx/node and environment are clean');
