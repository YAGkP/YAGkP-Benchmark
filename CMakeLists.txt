cmake_minimum_required(VERSION 3.21)

project(YAGkP-Benchmark
    DESCRIPTION "Benchmark of YAGkP against METIS, KaHIP and SCOTCH"
    LANGUAGES   C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# =============================================================================
# yagkp_bench: один запуск любого решателя с замером времени и метрик
#
# Флаги компиляции здесь не задаются: их передаёт build.sh (scripts/lib/flags.sh),
# одни и те же для раннера, YAGkP и сторонних библиотек.
#
# Сторонние библиотеки собирают scripts/deps/*.sh в BENCH_DEPS_DIR.
# YAGkP подключается из BENCH_YAGKP_DIR (по умолчанию подмодуль
# external/YAGkP-Lib): её чтение графа и метрики раннер использует для всех
# решателей
# =============================================================================
set(BENCH_YAGKP_DIR "${PROJECT_SOURCE_DIR}/external/YAGkP-Lib" CACHE PATH
    "Исходники YAGkP-Lib")
set(BENCH_DEPS_DIR "${PROJECT_SOURCE_DIR}/deps/seq" CACHE PATH
    "Каталог с собранными сторонними библиотеками")

# -----------------------------------------------------------------------------
# bench_import_dep(<цель> <библиотека> <файл .a>)
#   Импортированная статическая библиотека из ${BENCH_DEPS_DIR}/<библиотека>
#   с её каталогом include/. Если файла нет, сразу понятная ошибка
# -----------------------------------------------------------------------------
function(bench_import_dep target lib archive)
    set(prefix "${BENCH_DEPS_DIR}/${lib}")
    set(path   "${prefix}/lib/${archive}")

    if(NOT EXISTS "${path}")
        message(FATAL_ERROR
            "Не найдена сторонняя библиотека: ${path}\n"
            "Соберите их:  bash scripts/deps/all.sh")
    endif()

    add_library(${target} STATIC IMPORTED)
    set_target_properties(${target} PROPERTIES
        IMPORTED_LOCATION             "${path}"
        INTERFACE_INCLUDE_DIRECTORIES "${prefix}/include")
endfunction()

bench_import_dep(dep_gklib     gklib  libGKlib.a)
bench_import_dep(dep_metis     metis  libmetis.a)
bench_import_dep(dep_scotch    scotch libscotch.a)
bench_import_dep(dep_scotcherr scotch libscotcherr.a)
bench_import_dep(dep_kahip     kahip  libkahip_static.a)

# KaHIP собран в 64-битном режиме (scripts/deps/kahip.sh): kahip_idx в
# kaHIP_interface.h должен быть int64_t и в нашем коде
set_property(TARGET dep_kahip PROPERTY INTERFACE_COMPILE_DEFINITIONS KAHIP_64BIT)

# Зависимости между ними: METIS использует GKlib, GKlib — libm
target_link_libraries(dep_metis  INTERFACE dep_gklib)
target_link_libraries(dep_gklib  INTERFACE m)
target_link_libraries(dep_scotch INTERFACE dep_scotcherr)

# -----------------------------------------------------------------------------
# YAGkP: только библиотека, без её приложений. Вариант (YAGKP_PARALLEL)
# передаёт build.sh
# -----------------------------------------------------------------------------
if(NOT EXISTS "${BENCH_YAGKP_DIR}/CMakeLists.txt")
    message(FATAL_ERROR
        "Не найдены исходники YAGkP: ${BENCH_YAGKP_DIR}\n"
        "Получите подмодуль: git submodule update --init external/YAGkP-Lib")
endif()
set(YAGKP_BUILD_APPS OFF CACHE BOOL "" FORCE)
add_subdirectory("${BENCH_YAGKP_DIR}" yagkp EXCLUDE_FROM_ALL)

# -----------------------------------------------------------------------------
# Раннер
# -----------------------------------------------------------------------------
add_executable(yagkp_bench
    src/main.cpp
    src/solvers.cpp
)

target_compile_options(yagkp_bench PRIVATE
    $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall -Wextra>
)

target_link_libraries(yagkp_bench PRIVATE
    yagkp
    dep_kahip
    dep_metis
    dep_scotch
)

message(STATUS "")
message(STATUS "YAGkP-Benchmark")
message(STATUS "  CXX flags    ${CMAKE_CXX_FLAGS_RELEASE}")
message(STATUS "  YAGkP        ${BENCH_YAGKP_DIR}")
message(STATUS "  Deps         ${BENCH_DEPS_DIR}")
message(STATUS "")
