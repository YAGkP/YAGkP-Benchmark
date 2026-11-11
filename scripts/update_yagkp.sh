#!/usr/bin/env bash
# =============================================================================
# Moves the submodule external/YAGkP-Lib to the latest commit of main and
# stages the change; the commit is left to you
#
#   bash scripts/update_yagkp.sh
# =============================================================================
set -euo pipefail
# shellcheck source=lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

init_submodule external/YAGkP-Lib
old="$(git -C "$BENCH_ROOT/external/YAGkP-Lib" rev-parse --short HEAD)"
git -C "$BENCH_ROOT" submodule update --remote external/YAGkP-Lib
git -C "$BENCH_ROOT" add external/YAGkP-Lib
new="$(git -C "$BENCH_ROOT/external/YAGkP-Lib" rev-parse --short HEAD)"

if [ "$old" = "$new" ]; then
	ok "YAGkP-Lib is already at the latest main: $new"
else
	ok "YAGkP-Lib: $old -> $new; to keep it: git commit -m \"Update YAGkP-Lib\""
fi