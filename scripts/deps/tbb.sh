#!/usr/bin/env bash
# =============================================================================
# oneTBB: the threading library KaMinPar runs on
# =============================================================================
set -euo pipefail
# shellcheck source=../lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=../lib/deps.sh
source "$BENCH_ROOT/scripts/lib/deps.sh"

usage() {
	deps_usage tbb "Builds oneTBB from external/oneTBB (needed by KaMinPar)."
}

parse_common_args "$@"
deps_begin tbb external/oneTBB

#   BUILD_SHARED_LIBS=ON  TBB is meant to be a shared library; the runner
#                         finds libtbb.so through the RPATH set by CMake
#   TBB_TEST=OFF          the tests take long to build
#   TBB_STRICT=OFF        otherwise warnings of new compilers become errors
deps_configure \
	-DBUILD_SHARED_LIBS=ON \
	-DTBB_TEST=OFF \
	-DTBB_EXAMPLES=OFF \
	-DTBB_STRICT=OFF
cmake --build "$DEP_BUILD" --parallel "$JOBS"
cmake --install "$DEP_BUILD"

deps_finish
