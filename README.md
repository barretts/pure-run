# Pure command runner

`pure` runs commands with the direct Homebrew Node, npm, and npx binaries. It
removes the caller's environment, uses a new private home, and keeps
`~/.local/bin` and `~/.devbar/bin` out of `PATH`. The home is removed when the
command exits. The current directory and project files remain available.

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
