# Demo 3: Test the Legacy Code

**Minimum tier:** Small for single functions, Medium for the whole folder in one session · **Result:** a passing test suite, a real bug found, and proof the tests have teeth.

Three utility functions, written years ago, in production use, never tested. One of them has a bug in an edge case. That is not a contrivance; it is the normal state of engineering code.

## The starter prompt

Start your agent in this folder and paste:

```
The functions convertPressure.m, windowedStats.m, and parseLogEntry.m have
no tests. The intended behavior of each is documented in its help text.
Write a matlab.unittest test class for each function covering normal cases
and edge cases, run the tests, and report any function whose behavior does
not match its documentation. Put the tests in a tests/ subfolder, and have
each test class add the demo folder to the path in TestClassSetup with
matlab.unittest.fixtures.PathFixture so the tests find the functions.
```

On Small tier, do one function per session instead, starting with `windowedStats.m`.

## What success looks like

The agent writes and runs three test classes. Two suites pass. The tests for `windowedStats` fail on the trailing-window case: the help text promises that a final partial window is included, and the implementation drops it. The agent reports the discrepancy (fixing it is your call; the tests documented it either way).

## Verify

```matlab
verifyDemo
```

Checks that tests exist and pass against the documented behavior, then runs the mutation check: it swaps the seeded wrong-constant mutant from `mutants/` in for the real `convertPressure.m`, reruns your tests, confirms at least one test that passed before now fails, and restores the original. Green tests that cannot catch a wrong constant are decoration; this proves yours are not.
