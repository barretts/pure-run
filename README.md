# Pure command runner

`pure` runs commands with the direct Homebrew Node, npm, and npx binaries. It
removes the caller's environment, uses a new private home, and keeps
`~/.local/bin` and `~/.devbar/bin` out of `PATH`. The home is removed when the
command exits. The current directory and project files remain available.

## Install

From this local checkout on macOS, with Homebrew Node/npm/npx already present:

```sh
cd ~/code/pure-run
./install.sh
```

The installer links `pure` into `~/.local/bin`, checks command resolution, and
runs a real npm smoke test. It is safe to run again. It refuses to overwrite a
different existing command and does not edit shell startup files. On this Mac,
`~/.local/bin` is already on `PATH`; `command -v pure` should show the link.
Keep this checkout in place while using the link. The installer can also link
into another command directory with `--bin-dir`.

To install the separate agent evaluation prefix too, use:

```sh
./install.sh --with-evals
```

That option uses `~/code/eval-agents/install.sh`, installs under
`~/opt/pure-evals/eval-agents`, and runs its doctor. The agent installer needs
the existing gateway credentials and CA files and snapshots Claude auth from
DevBar at install time. Its staging build can take several minutes. Supply
`--eval-source /absolute/path` if the eval installer checkout is elsewhere.

`--bin-dir /absolute/path` selects a different command directory. Add that
directory to your shell `PATH` yourself if you choose one.

The local runner source has no published remote or package registry entry;
`./install.sh` is the installable method from this checkout.

Examples:

```sh
pure npm test
pure npx --no-install playwright test
pure shell
pure --home ~/opt/pure-profiles/eval shell
pure eval opencode --version
pure eval claude --version
pure --pass-env GEMINI_API_KEY -- my-evaluator run
pure inspect
```

Inside `pure shell`, `npm test` and any other commands inherit the clean
environment. Exit the shell to remove its temporary home. Use `--home` for a
separate persistent profile when an evaluation needs several sessions. The
profile can hold its own credentials and caches; never point it at your usual
home or DevBar directory.

The runner excludes inherited proxy, certificate, telemetry, Node, npm, and
agent variables. It uses separate empty files for user and global npm configuration,
while keeping project `.npmrc` files. `--pass-env NAME` imports only a named
variable and refuses names that would override isolation.
Automatic npm update notices, audit requests, and fund output are disabled;
explicit `npm audit` commands remain available.

This controls the launch environment and command resolution. A project's own
scripts, dependencies, or an explicitly chosen external executable can still
perform their usual behavior. Inspect those separately for a fully clean
evaluation. `pure eval NAME` uses the separate installed prefix at
`~/opt/pure-evals/eval-agents`. It is installed from `~/code/eval-agents` with
Homebrew Node and npm, and starts with its own application profiles. The
installer snapshots gateway credentials and CA files at install time. `pure`
does not inherit DevBar or AI Suite settings at runtime.
Claude's global enterprise managed settings still apply to its binary, as
reported by the evaluation installer's doctor. Live provider inference was
not part of the isolation smoke checks.
