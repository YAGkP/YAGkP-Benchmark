#!/usr/bin/env bash
# =============================================================================
# Сборка раннера yagkp_bench. Справка: bash build.sh --help
# =============================================================================
set -euo pipefail
# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib/common.sh"
# shellcheck source=scripts/lib/flags.sh
source "$BENCH_ROOT/scripts/lib/flags.sh"

DEFAULT_YAGKP_DIR="$BENCH_ROOT/external/YAGkP-Lib"

usage() {
	cat <<'USAGE'
Использование: bash build.sh [опции]

Собирает METIS, KaHIP, SCOTCH (scripts/deps/, при первом запуске и при
изменении флагов), YAGkP и раннер yagkp_bench, все с одними и теми же флагами.
Результат: build/<вариант>/yagkp_bench и build/<вариант>/build_info.txt

YAGkP:
  --yagkp-dir <путь>   исходники YAGkP-Lib, например рабочая копия рядом
                       (по умолчанию подмодуль external/YAGkP-Lib)

USAGE
	common_args_help
	echo "  (--clean пересобирает только раннер; библиотеки: scripts/deps/all.sh --clean)"
}

YAGKP_DIR="$DEFAULT_YAGKP_DIR"
_expect_dir=0
parse_extra_arg() {
	case "$1" in
		--yagkp-dir) _expect_dir=1 ;;
		*)
			if [ "$_expect_dir" -eq 1 ]; then
				YAGKP_DIR="$(cd "$1" && pwd)" || die "нет каталога $1"
				_expect_dir=0
			else
				return 1
			fi
			;;
	esac
}

parse_common_args "$@"
[ "$_expect_dir" -eq 0 ] || die "--yagkp-dir: ожидается путь"

if [ "$YAGKP_DIR" = "$DEFAULT_YAGKP_DIR" ]; then
	init_submodule external/YAGkP-Lib
fi

# Сторонние библиотеки однопоточные: и для --par используется их
# последовательная сборка deps/seq
bash "$BENCH_ROOT/scripts/deps/all.sh" --seq -j "$JOBS"

require_cmd cmake
load_flags
BUILD_DIR="$BENCH_BUILD_ROOT/$VARIANT"

step "yagkp_bench ($VARIANT) -> ${BUILD_DIR#"$BENCH_ROOT"/}"
print_flags
if [ "$CLEAN" -eq 1 ]; then
	info "Удаляю ${BUILD_DIR#"$BENCH_ROOT"/}"
	rm -rf "$BUILD_DIR"
fi

parallel=OFF
if [ "$VARIANT" = "par" ]; then
	parallel=ON
fi

cmake -S "$BENCH_ROOT" -B "$BUILD_DIR" \
	"${CMAKE_FLAG_ARGS[@]}" \
	-DBENCH_YAGKP_DIR="$YAGKP_DIR" \
	-DBENCH_DEPS_DIR="$BENCH_DEPS_ROOT/seq" \
	-DYAGKP_PARALLEL="$parallel"
cmake --build "$BUILD_DIR" --parallel "$JOBS"

# -----------------------------------------------------------------------------
# Что собрано: run_benchmark.sh копирует это в info.txt каждого прогона
# -----------------------------------------------------------------------------
commit_of() { # commit_of <каталог>: коммит и пометка о незакоммиченных правках
	local hash
	hash="$(git -C "$1" rev-parse --short HEAD 2>/dev/null)" || {
		echo "unknown"
		return
	}
	if git -C "$1" status --porcelain --untracked-files=no 2>/dev/null | grep -q .; then
		hash="$hash (uncommitted changes)"
	fi
	echo "$hash"
}

{
	echo "built:     $(date)"
	echo "variant:   $VARIANT"
	echo "flags:     $BENCH_CXXFLAGS"
	echo "compiler:  $("${CXX:-c++}" --version 2>/dev/null | head -n 1)"
	echo "bench:     $(commit_of "$BENCH_ROOT")"
	echo "yagkp:     $(commit_of "$YAGKP_DIR") in $YAGKP_DIR"
	for lib in gklib metis scotch kahip; do
		echo "$(printf '%-10s' "$lib:") $(grep '^source:' "$BENCH_DEPS_ROOT/seq/$lib/.stamp" | awk '{print substr($2, 1, 7)}')"
	done
} >"$BUILD_DIR/build_info.txt"

ok "${BUILD_DIR#"$BENCH_ROOT"/}/yagkp_bench"
sed 's/^/    /' "$BUILD_DIR/build_info.txt" >&2
