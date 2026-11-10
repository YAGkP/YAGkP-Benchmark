# YAGkP-Benchmark

Benchmarks for [Yet Another Graph k-Partition Library (YAGkP)](https://github.com/YAGkP/YAGkP-Lib) and other partitioners: edge cut, imbalance and running time on the graph sets of [YAGkP-Graphs](https://github.com/YAGkP/YAGkP-Graphs). All partitioners are built from source with the same compiler flags.

## Partitioners

| partitioner | link | version | algorithms in the benchmark |
|---|---|---|---|
| YAGkP | [YAGkP-Lib](https://github.com/YAGkP/YAGkP-Lib) | sequential and parallel, shared memory (OpenMP) | `yagkp`: multilevel recursive bisection |
| METIS | [KarypisLab/METIS](https://github.com/KarypisLab/METIS) | sequential | `metis_recursive`, `metis_kway` |
| KaHIP | [KaHIP/KaHIP](https://github.com/KaHIP/KaHIP) | sequential (KaFFPa) | `kahip_fast`, `kahip_eco`, `kahip_strong` |
| SCOTCH | [live-clones/scotch](https://github.com/live-clones/scotch) | sequential | `scotch` |
