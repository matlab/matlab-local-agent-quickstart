# Demo 1: Fix the Error

**Minimum tier:** Small · **Time:** about five minutes · **Result:** a failing pipeline runs green, with the root cause named.

A telemetry-processing pipeline fails with a size-mismatch error deep in the call chain. The bug is real, subtle, and of a kind every MATLAB&reg; engineer has written at least once.

## Setup

In MATLAB, from this folder:

```matlab
makeTelemetryData    % writes telemetry.csv (deterministic, seeded)
runPipeline          % fails with an error
```

## The starter prompt

Start your agent in this folder and paste:

```
runPipeline.m in this folder fails when processing telemetry.csv. Run it,
find the root cause of the error, fix it, and run it again to confirm the
pipeline completes. Then state the root cause in one sentence.
```

## What success looks like

The agent runs the pipeline, reads the error, traces it to the cleaning step, fixes it, reruns, and reports something equivalent to: "cleanSignals deleted NaN elements with linear indexing, collapsing the matrix to a vector; row-wise deletion preserves the channel structure."

## Verify

```matlab
verifyDemo
```

Checks that the pipeline completes and the metrics have the correct shape and values.

## If it goes sideways

On Small tier the agent may need one nudge ("run the pipeline first and read the error message"). If the agent narrates a fix without calling tools, see [troubleshooting.md](../../docs/troubleshooting.md), item 2.
