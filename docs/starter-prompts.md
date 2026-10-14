# Starter Prompts

Local models work best on bounded tasks with verifiable outcomes. This page lists some example prompts that can be adapted to your code.

Each example prompt:
- names the files we want the agent to work on.
- states certain constraints.
- asks the agent to verify the result (for example, by running the final code).

These three points are useful for keeping a small model on track.

## Tips for Writing Prompts

An example of a weak prompt would be:

    Improve my code.

A better prompt would be:

    Fix every Code Analyzer warning in `signalFilter.m` without changing its behavior. Re-check after each change and run the tests in tests/ to confirm.

Make sure your prompts names the file you want to work on, a specific goal, and a way that the agent can verify the result.

## Example Prompts

**Diagnose an error:**
```
runAnalysis.m fails when processing shipment_march.csv. Run it, read the
error, find the root cause, fix it, and run it again to confirm. State the
root cause in one sentence.
```

**Add tests to one function:**
```
Write a matlab.unittest test class for computeThrust.m covering normal
operation and edge cases (zero input, empty input, out-of-range values).
Run the tests and report which pass. The intended behavior is documented in
the function help text.
```

**Clear analyzer warnings:**
```
Fix every Code Analyzer warning in legacyImport.m without changing its
behavior. Re-check with the analyzer after each change. Behavior is defined
by the tests in tests/tLegacyImport.m; keep them green.
```

**Explain unfamiliar code:**
```
Read processCalibration.m and explain what it computes, section by section,
in plain language. Flag anything that looks like a bug or an unstated
assumption, but do not change the file.
```

**Vectorize with proof:**
```
estimateLoads.m has loops that MATLAB can vectorize. Optimize it, verify
the outputs match the original on the data in sample_loads.mat, and measure
the before and after with timeit. Report the speedup.
```

**Bounded data question:**
```
Load pressure_log.csv into a timetable. Report the daily mean and maximum
pressure, and the timestamp of the single highest reading. Show the code
you ran and the numeric answers.
```

## Tips for Success with Local Models

- Keep requests narrow and specific (mentioning only one function, one error or one question per session). Start new sessions often to prevent the context window from running out.
- State how to do the verification in the prompt ("run the tests", "re-check the analyzer", "verify against the original"). The model will then run the verification in MATLAB instead of narrating success.
- When the output degrades mid-session, it often means the context window has run out. You can try starting a new session with a prompt that summarises the previous session ("the fix so far is X; continue by Y").
- If the agent describes an action instead of doing it, say "call the tool." If that recurs, see [troubleshooting.md](troubleshooting.md).
