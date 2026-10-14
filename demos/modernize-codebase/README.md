# Demo 2: Modernize the Codebase

**Minimum tier:** Small-Medium · **Result:** Code Analyzer warning count to zero, test suite green before and after, outputs proven equivalent.

Two working functions written in an older MATLAB&reg; style: growing arrays inside loops, `str2num` on untrusted strings, string searches from a decade ago. The Code Analyzer flags all of it. Your agent's job is to clear the warnings without changing behavior, and to prove it.

This is the most local-friendly workflow in the Quickstart: the Code Analyzer hands the model a precise, machine-checkable target every turn, so even a Small-tier model converges.

The patterns seeded here (`str2num` on scalars, `isempty(strfind(...))`, arrays growing inside loops) come from the same review checklist the [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit) teaches through its `matlab-review-code` and `matlab-modernize-code` skills. On Medium tier with the matlab-core skill group installed, those skills and this demo reinforce each other; on Small tier the demo works without them.

## Setup

Confirm the starting state in MATLAB, from this folder:

```matlab
checkcode processReadings.m summarizeReadings.m   % lists the warnings
runtests("tests")                                  % passes: the safety net
```

## The starter prompt

Start your agent in this folder and paste:

```
processReadings.m and summarizeReadings.m have Code Analyzer warnings. Fix
every warning without changing the functions' behavior. After each change,
re-check with the Code Analyzer and run the tests in tests/ to confirm they
still pass. Do not modify anything in original/ or tests/. Stop when the
warning count is zero and the tests are green.
```

## Verify

```matlab
verifyDemo
```

Three checks: Code Analyzer reports zero issues, the test suite passes, and `backToBackCheck` confirms the modernized functions produce the same outputs as the untouched copies in `original/` on representative inputs. That last check is the one that makes the result trustworthy; use the same helper on your own code.
