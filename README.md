# YAGkP-Benchmark

Benchmarks for [Yet Another Graph k-Partition Library (YAGkP)](https://github.com/YAGkP/YAGkP-Lib) and other partitioners: edge cut, imbalance and running time on the graph sets of [YAGkP-Graphs](https://github.com/YAGkP/YAGkP-Graphs). All partitioners are built from source with the same compiler flags.

## Partitioners

| partitioner | link | type | version | algorithms in the benchmark |
|---|---|---|---|---|
| YAGkP | [YAGkP-Lib](https://github.com/YAGkP/YAGkP-Lib) | sequential and parallel, shared memory (OpenMP) | latest `main` | `yagkp`: multilevel recursive bisection |
| METIS | [KarypisLab/METIS](https://github.com/KarypisLab/METIS) | sequential | `master` of 2026-06-10 (`272d4a9`), after v5.2.1 | `metis_recursive`, `metis_kway` |
| KaHIP | [KaHIP/KaHIP](https://github.com/KaHIP/KaHIP) | sequential (KaFFPa) | v3.25 | `kahip_fast`, `kahip_eco`, `kahip_strong` |
| SCOTCH | [live-clones/scotch](https://github.com/live-clones/scotch) | sequential and parallel, shared memory (POSIX threads) | v7.0.18 | `scotch` |
| mt-metis | [mt-metis](https://dlasalle.github.io/mt-metis/) | parallel, shared memory (OpenMP) | 0.7.2 | `mtmetis_kway`, `mtmetis_recursive` |
| KaMinPar | [KaHIP/KaMinPar](https://github.com/KaHIP/KaMinPar) | parallel, shared memory (TBB) | v3.7.4, with oneTBB v2022.2.0 | `kaminpar_fast`, `kaminpar_default`, `kaminpar_eco` |

The parallel solvers (`yagkp_bench --threaded-algos`) run with the thread counts of `THREADS` in a plan, the others with 1 thread. For example, a plan comparing the parallel solvers:

```bash
SOLVERS=(yagkp scotch mtmetis_kway kaminpar_default)
THREADS=(1 2 4 8)
VARIANT=par
```

`OMP_PROC_BIND` and `OMP_PLACES` pin the threads of the OpenMP solvers (YAGkP, mt-metis) only.
