# Troubleshooting

Here are a list of potential failure modes you may encounter will a local agent setup. The first two are the most common.

## 1. The agent forgets instructions mid-session, or stops calling tools

**Cause:** Context overflow. The runtime is serving a smaller context than you think (runtime defaults are usually well below what the model supports), or your session outgrew the window and the oldest content was silently dropped.

**Fix:** set the context explicitly per your runtime guide (Modelfile `num_ctx`, LM Studio load setting, llama.cpp `-c`). Confirm with `verifySetup`, which prints the budget actually in effect. If the window is already at your tier's ceiling, the fix is a smaller task: one function, one error, fresh session.

## 2. Malformed tool calls, or the agent narrates instead of acting

**Cause:** Tool-calling is the weakest capability of small local models. The model emits broken JSON, invents tool names, or describes what it would do instead of calling the tool.

**Fix, in order:** (a) confirm you are on the tier's recommended model, not something smaller; (b) reduce the number of registered tools to the three-tool minimal set; (c) retry the task with a more explicit prompt naming the tool; (d) adjust expectations: Small-tier models can currently be expected to give assisted help, but are not yet capable of robustly performing autonomous loops.

## 3. Skills never trigger, or make things worse

**Cause:** Skill triggering relies on the model recognizing when to load a skill. Small models under-trigger; when skills do load, they consume budget the task needed.

**Fix:** on Small tier, run without skills (the default). On Medium, install one skill group at a time and invoke skills explicitly by name rather than expecting automatic triggering.

## 4. Runaway generation or premature stops (llama.cpp especially)

**Cause:** Chat-template or stop-token mismatch between the model and the server configuration.

**Fix:** Update to a current runtime build (templates ship in GGUF metadata); if the model needs an explicit template, pass it per the llama.cpp guide.

## 5. Generation got drastically slower after raising the context

**Cause:** The KV cache at the larger context pushed total memory past your GPU or unified-memory capacity, forcing offload to CPU.

**Fix:** Reduce context budget, or move to a smaller quantization. This will leave space in the GPU or unified memory for the KV cache.

## 6. Verification passes but MATLAB tool results never come back

**Cause:** MCP server not started, wrong binary path in the harness config, or MATLAB session mode mismatch.

**Fix:** Run `verifySetup`, which should name the failing link. Re-check the MCP server path in your config template and consult the [MATLAB MCP Server documentation](https://github.com/matlab/matlab-mcp-server) for session options.

## Reporting

Should you encounter an issue using this Quickstart, please open a GitHub issue with your model tier, runtime and version, harness and version, model and quantization, and the `verifySetup` output.