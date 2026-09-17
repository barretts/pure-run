#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(/usr/bin/dirname "$0")/.." && pwd)
WORK=$(/usr/bin/mktemp -d)
trap '/bin/rm -rf "$WORK"' EXIT

"$ROOT/install.sh" --bin-dir "$WORK/bin" > "$WORK/first.log" 2>&1
"$ROOT/install.sh" --bin-dir "$WORK/bin" > "$WORK/second.log" 2>&1
[ -L "$WORK/bin/pure" ]
[ "$(/usr/bin/readlink "$WORK/bin/pure")" = "$ROOT/pure" ]

/bin/mkdir -p "$WORK/conflict"
printf 'existing command\n' > "$WORK/conflict/pure"
if "$ROOT/install.sh" --bin-dir "$WORK/conflict" > "$WORK/conflict.log" 2>&1; then
  echo 'installer overwrote or accepted an existing command' >&2
  exit 1
fi
[ "$(/bin/cat "$WORK/conflict/pure")" = 'existing command' ]
echo 'install smoke passed: custom bin, repeat install, existing command preserved'
