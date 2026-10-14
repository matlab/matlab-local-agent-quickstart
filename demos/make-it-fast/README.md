# Demo 4: Make It Fast

**Minimum tier:** Medium · **Result:** a measured speedup multiple, from a correct measurement.

`slowAnalysis.m` computes windowed statistics and anomaly flags over a 200,000-sample signal. It is correct, and it is slow in ways experienced readers will recognize: element-by-element loops over things MATLAB&reg; vectorizes, and arrays that grow inside loops. Measured speedup after proper vectorization: 30x or more.

The demo also teaches the measurement discipline: speedups are claimed with `timeit`, which handles warm-up and repetition, not with a single `tic`/`toc`, which measures noise as often as it measures code.

## The starter prompt

Start your agent in this folder and paste:

```
slowAnalysis.m is correct but slow. Optimize it without changing its
outputs. Measure before and after with timeit (not tic/toc), and verify the
optimized version produces the same outputs as the copy in baseline/ on the
same input. Report the speedup multiple and what you changed. Do not modify
baseline/.
```

## Verify

```matlab
verifyDemo
```

Times the baseline and the optimized version with `timeit`, checks output equivalence against `baseline/` with a small floating-point tolerance (summation order changes when code vectorizes), and reports the speedup. Pass requires equivalent outputs and at least a 5x improvement. Measured on the shipped implementation: 33.9x.
