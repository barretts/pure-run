# Clean test and evaluation design

## Discovery on 2026-09-17

- The login and interactive shell put `~/.local/bin` ahead of Homebrew.
- `~/.local/bin/npm` and `npx` forward to `~/.devbar/bin`.
- Other commands in `~/.local/bin` also forward to DevBar packages.
- `~/opt/eval-agents/bin/node` forwarded to DevBar's Node, so a PATH change
  alone did not clean that evaluation installation.
- The caller's environment included a Node CA setting, agent notification
  variables, and other agent settings. The existing OpenCode evaluation
  profiles retained private skills.

## Implemented controls

1. `pure COMMAND` builds an allowlisted environment and a fresh temporary
   home, then launches the command from the same working directory. Homebrew
   and system tools are the only PATH entries.
2. npm user and global configs, caches, and global prefix go into the private
   home. Project `.npmrc` files remain visible because they are project inputs.
   Automatic npm update notices, audit requests, and fund output are disabled.
3. `pure shell` starts `zsh -f` with `ZDOTDIR` in the private home. This avoids
   the user's startup functions and PATH changes for the whole shell session.
4. `pure eval NAME` launches the named binary in a separate evaluation prefix,
   installed using direct Homebrew Node and npm. The install-time gateway and
   CA snapshots live in that prefix; runtime does not use DevBar command
   wrappers or inherited agent variables.
5. `--home DIRECTORY` selects a separate persistent home for work spanning
   runs, and `--pass-env NAME` imports one explicit variable for an evaluation
   that needs a credential. Variables that alter process loaders, startup,
   npm, Node, proxy, certificate, telemetry, or DevBar state are refused.
6. `install.sh` links the runner from this checkout without replacing an
   unrelated command, runs the npm smoke test, and can install the separate
   evaluation prefix with `--with-evals`.

## Proof and boundary

`tests/smoke.sh` launches a real `npm test` fixture. Its Node test script
spawns `npm` and `npx`, checks their paths and versions against Homebrew, and
checks that inherited proxy, Node, CA, and agent notification variables are
absent. It also checks a noninteractive clean shell and rejects an explicit
DevBar executable. An interactive shell check verifies command resolution and
temporary-home cleanup.

The command controls launch state and ordinary subprocess lookup. Project
scripts or dependencies can still make external calls or invoke absolute
executables. A fully clean evaluation must inspect those project inputs and
the agent's own configuration as well. The separate evaluation installer has
its own doctor and offline runtime tests for the installed agent binaries.

## Verification on 2026-09-17

- `tests/smoke.sh` passed with a real `npm test` and child `npm`/`npx` calls.
- An interactive `pure shell` resolved Node tools to Homebrew and removed its
  temporary home after exit.
- The separate evaluation prefix installed successfully with
  `node_bin=/opt/homebrew/bin/node` in its manifest.
- All four `pure eval NAME --version` commands passed. The separate prefix's
  doctor passed under `pure`.
- The offline runtime suite passed under `pure` for OpenCode v1, OpenCode v2,
  and Crush, including mock inference, project inputs, shell and MCP child
  environments, and Crush's HTTPS CA snapshot.

Live provider inference was not run. Claude's global enterprise managed
settings still apply to its binary on this Mac; the installer doctor reports
this. These are application-level limits of the installed agents, outside the
DevBar command and environment isolation supplied by `pure`.
