# Agent Guidance

This repository helps users set up and evaluate local LLM + MATLAB agentic workflows. If you are an AI agent working in this repo, these notes keep you effective on a small context budget.

- Use the MATLAB MCP tools to verify everything: run code with `evaluate_matlab_code`, tests with `run_matlab_test_file`, analysis with `check_matlab_code`. Never claim MATLAB behavior without running it.
- Work on one file or one function at a time. Do not read entire folders into context.
- When executing a demo task, work from the starter prompt you were given. Do not open the demo folder's README.md or verifyDemo.m; they state expected outcomes, and reading them defeats the evaluation.
- Do not modify files in `original/`, `baseline/`, or `mutants/` folders; they are reference copies the verification depends on.
- MATLAB code in this repo follows MathWorks style: functions with `arguments` blocks where signatures need validation, `string` over `char` for new code, errors with identifiers.
