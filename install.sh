#!/bin/sh
# Install the runner from this checkout; optionally install the separate eval CLIs.
set -eu

SOURCE_DIR=$(CDPATH= cd -- "$(/usr/bin/dirname "$0")" && pwd)
BIN_DIR="$HOME/.local/bin"
EVAL_SOURCE="$HOME/code/eval-agents"
WITH_EVALS=0

usage() {
  cat <<USAGE
Usage: $0 [--bin-dir ABSOLUTE_DIRECTORY] [--with-evals] [--eval-source DIRECTORY]

Install a symlink for pure into the selected bin directory (default: ~/.local/bin).
--with-evals also installs the separate agent prefix at ~/opt/pure-evals/eval-agents.
--eval-source selects the eval-agents installer checkout (default: ~/code/eval-agents).
USAGE
}

fail() {
  echo "pure install: $*" >&2
  exit 2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --bin-dir|--eval-source)
      [ "$#" -ge 2 ] || fail "$1 needs a value"
      if [ "$1" = --bin-dir ]; then BIN_DIR=$2; else EVAL_SOURCE=$2; fi
      shift 2
      ;;
    --with-evals) WITH_EVALS=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
done

[ "$(/usr/bin/uname -s)" = Darwin ] || fail "this installer supports macOS"
case "$BIN_DIR" in
  /*) ;;
  *) fail "--bin-dir must be an absolute path" ;;
esac
case "$BIN_DIR" in
  */.devbar|*/.devbar/*) fail "the bin directory must be outside DevBar" ;;
esac

TOOL_BIN=
for candidate in /opt/homebrew/bin /usr/local/bin; do
  if [ -x "$candidate/node" ] && [ -x "$candidate/npm" ] && [ -x "$candidate/npx" ]; then
    TOOL_BIN=$candidate
    break
  fi
done
[ -n "$TOOL_BIN" ] || fail "install a direct Homebrew Node/npm/npx toolchain first"
[ -x /usr/bin/python3 ] || fail "missing /usr/bin/python3"
[ -x "$SOURCE_DIR/pure" ] || fail "missing executable $SOURCE_DIR/pure"
if [ "$WITH_EVALS" -eq 1 ]; then
  [ -x "$EVAL_SOURCE/install.sh" ] || fail "missing executable $EVAL_SOURCE/install.sh"
  [ -x "$EVAL_SOURCE/doctor.sh" ] || fail "missing executable $EVAL_SOURCE/doctor.sh"
fi

/bin/mkdir -p "$BIN_DIR"
TARGET="$BIN_DIR/pure"
if [ -L "$TARGET" ]; then
  [ "$(/usr/bin/readlink "$TARGET")" = "$SOURCE_DIR/pure" ] || fail "$TARGET is a symlink to another target; leaving it alone"
elif [ -e "$TARGET" ]; then
  fail "$TARGET already exists; leaving it alone"
else
  /bin/ln -s "$SOURCE_DIR/pure" "$TARGET"
fi

"$TARGET" inspect >/dev/null
PURE="$TARGET" "$SOURCE_DIR/tests/smoke.sh"
echo "pure install: runner ready at $TARGET"

if [ "$WITH_EVALS" -eq 1 ]; then
  EVAL_PREFIX="$HOME/opt/pure-evals/eval-agents"
  EVAL_AGENTS_PREFIX="$EVAL_PREFIX" PATH="$TOOL_BIN:/usr/bin:/bin:/usr/sbin:/sbin" \
    /bin/bash "$EVAL_SOURCE/install.sh"
  EVAL_AGENTS_PREFIX="$EVAL_PREFIX" "$TARGET" --pass-env EVAL_AGENTS_PREFIX \
    /bin/bash "$EVAL_SOURCE/doctor.sh" > "$EVAL_PREFIX/logs/pure-run-doctor.log" 2>&1 || {
      /usr/bin/tail -25 "$EVAL_PREFIX/logs/pure-run-doctor.log" >&2
      fail "evaluation doctor failed"
    }
  echo "pure install: evaluation prefix ready at $EVAL_PREFIX (doctor passed)"
fi
