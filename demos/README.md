# Demos

Five demos prove your setup does real engineering work. Each one starts from code or data that looks like what you already have, gives your agent a bounded task, and ends in a number you can verify: a bug found, a warning count at zero, a measured speedup, a fault frequency that matches physics.

Run them in this order:

1. **[Fix the Error](fix-the-error/)** (Small tier, five minutes): a data pipeline fails three functions deep; the agent finds the root cause, fixes it, and reruns.
2. **[Modernize the Codebase](modernize-codebase/)** (Small-Medium): the agent drives the Code Analyzer warning count to zero and proves behavior is unchanged with a back-to-back output check.
3. **[Test the Legacy Code](test-legacy-code/)** (Small-Medium): the agent writes a test suite for untested utilities, finds a real bug, and the tests prove they have teeth by catching a seeded mutant.
4. **[Make It Fast](make-it-fast/)** (Medium): the agent vectorizes a slow analysis and measures the speedup with `timeit`, not `tic`/`toc`.
5. **[Analyze the Sensor Data](analyze-sensor-data/)** (Medium): the agent finds a bearing fault frequency in vibration data; the answer is checkable against the bearing geometry.

Every demo folder contains a README with the exact starter prompt, the starter assets, and a `verifyDemo.m` that checks the outcome programmatically. All demos run on base MATLAB&reg;; no additional toolboxes required.

Two habits the demos teach on purpose: give the agent one bounded task at a time (a small model with a small context window does its best work that way), and verify outcomes with MATLAB rather than trusting the model's own account of what it did.