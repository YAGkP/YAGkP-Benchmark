# YAGkP-Benchmark

Benchmarks for [Yet Another Graph k-Partition Library (YAGkP)](https://github.com/YAGkP/YAGkP-Lib) and other partitioners: edge cut, imbalance and running time on the graph sets of [YAGkP-Graphs](https://github.com/YAGkP/YAGkP-Graphs). All partitioners are built from source with the same compiler flags.

## Partitioners

| partitioner | link | type | version | algorithms in the benchmark |
|---|---|---|---|---|
| YAGkP | [YAGkP-Lib](https://github.com/YAGkP/YAGkP-Lib) | sequential and parallel, shared memory (OpenMP) | latest `main` | `yagkp`: multilevel recursive bisection |
| METIS | [KarypisLab/METIS](https://github.com/KarypisLab/METIS) | sequential | `master` of 2026-06-10 (`272d4a9`), after v5.2.1 | `metis_recursive`, `metis_kway` |
| KaHIP | [KaHIP/KaHIP](https://github.com/KaHIP/KaHIP) | sequential (KaFFPa) | v3.25 | `kahip_fast`, `kahip_eco`, `kahip_strong` |
| SCOTCH | [live-clones/scotch](https://github.com/live-clones/scotch) | sequential | v7.0.18 | `scotch` |
