#!/bin/sh
set -eu
PURE=${PURE:-$(CDPATH= cd -- "$(/usr/bin/dirname "$0")/.." && pwd)/pure}
WORK=$(/usr/bin/mktemp -d)
trap '/bin/rm -rf "$WORK"' EXIT
/bin/cp "$(/usr/bin/dirname "$0")/child-probe.js" "$WORK/child-probe.js"
cat > "$WORK/package.json" <<'JSON'
{"name":"pure-run-probe","version":"1.0.0","private":true,"scripts":{"test":"node child-probe.js"}}
JSON
cd "$WORK"
export PURE_TEST_INHERITED_MARKER=1
export HTTPS_PROXY=http://127.0.0.1:1
export NODE_OPTIONS=--no-warnings
"$PURE" npm test
"$PURE" /bin/zsh -f -c 'test "$(command -v npm)" = "${PATH%%:*}/npm"; test -z "${PURE_TEST_INHERITED_MARKER-}"; test -z "${NODE_EXTRA_CA_CERTS-}"'
if [ -x "$HOME/.devbar/bin/npm" ]; then
  if "$PURE" "$HOME/.devbar/bin/npm" --version >/dev/null 2>&1; then
    echo 'pure accepted a direct DevBar executable' >&2
    exit 1
  fi
fi
echo 'pure smoke passed'
