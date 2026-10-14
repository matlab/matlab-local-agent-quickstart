# MATLAB Local Agent Quickstart

Run a local AI coding agent against MATLAB&reg;, with no code, data, or prompts sent off the machine.

This repository connects three pieces: a local LLM runtime, the
[OpenCode](https://opencode.ai) coding agent, and the
[MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server) with settings
tuned for local models, then verifies the result with five demos.

## Requirements

- MATLAB R2025a or later (R2025a enables the plain-text Live Script format one demo produces)
- Git&trade;
- The [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server)
- One local LLM runtime: [Ollama](https://ollama.com), [LM Studio](https://lmstudio.ai), or [llama.cpp](https://github.com/ggml-org/llama.cpp)
- One agentic coding tool: [OpenCode](https://opencode.ai)
- Hardware per the tier table below

## Step 1: Prepare

Get the repo:

```sh
git clone https://github.com/matlab/matlab-local-agent-quickstart.git
```

Then run the readiness check in MATLAB:

```matlab
cd matlab-local-agent-quickstart/prepare
checkLocalAI
```

It detects your memory, GPU, MATLAB version, Git, and Node.js&reg;, assigns your machine a tier, and prints the recommended model, quantization, context window, and harness. It makes no network calls.

| Tier | Hardware | Recommended model | Context | Harness | Skills |
|------|----------|-------------------|---------|---------|--------|
| Small | 16 GB Apple&reg; silicon; 12 GB NVIDIA&reg; GPU | Gemma 4 12B QAT, Q4 | 8k-16k | OpenCode | off |
| Medium | 32 GB+ Apple silicon; 24 GB+ NVIDIA GPU | Qwen3-Coder-30B-A3B, Q4_K_M | 16k-32k | OpenCode | curated |

Small tier supports single-step assisted help. Medium should be used for reliable autonomous work.

## Step 2: Set Up

Follow one guide per piece, in order:

1. **MATLAB MCP Server**: [download the binary and note its path](docs/setup-matlab-mcp-server.md).
2. **Runtime**: [Ollama](docs/setup-ollama.md) · [LM Studio](docs/setup-lmstudio.md) · [llama.cpp](docs/setup-llamacpp.md)
3. **Harness**: [OpenCode](docs/setup-opencode.md)

Each guide applies a template from `setup/configs/`: the runtime setup sets the context window explicitly, and the OpenCode template connects to your local endpoint and registers the MCP Server with telemetry disabled.

Set the context window with care. The context window is how much text the model can hold at once. Your code, the conversation, and the agent's own working notes all share it. Local runtimes default to a small window, often far below what the model is capable of. When a session outgrows that window, the oldest content is dropped silently: the agent appears to "forget" earlier files or instructions, with no error to signal why.

Then verify the whole stack from MATLAB, naming your runtime and your tier's context value:

```matlab
cd setup
verifySetup                                            % Ollama, Medium tier (16384)
verifySetup(runtime="lmstudio", contextTokens=12288)   % LM Studio, Small tier
verifySetup(runtime="llamacpp")                        % llama.cpp server
```

Verification confirms each link by name (runtime endpoint, model loaded, MCP Server binary if you pass its path) and prints the budget for the context window you configured: harness overhead, tool schemas, what remains for your code and conversation.

## Step 3: Run the Demos

Five demos, each with starter assets, the exact prompt to give your agent, and a verification script that checks the outcome.

| Demo | What happens | Minimum tier | The result you get |
|------|-------------|--------------|--------------------|
| [Fix the Error](demos/fix-the-error/) | Agent diagnoses and fixes a failing pipeline, then reruns it | Small | Error to green run, root cause named |
| [Modernize the Codebase](demos/modernize-codebase/) | Agent clears Code Analyzer warnings and proves behavior unchanged | Small-Medium | Warning count to zero, outputs verified equal |
| [Test the Legacy Code](demos/test-legacy-code/) | Agent writes and runs a test suite for untested utilities | Small-Medium | Passing suite, a real bug found, mutation check passed |
| [Make It Fast](demos/make-it-fast/) | Agent vectorizes a slow script and measures the speedup properly | Medium | Speedup multiple, measured with `timeit` |
| [Analyze the Sensor Data](demos/analyze-sensor-data/) | Agent finds a bearing fault frequency in vibration data and writes a report | Medium | Detected frequency vs. physics-predicted value |

Every demo runs on base MATLAB with no additional toolboxes. When you move from the demos to your own code, [docs/starter-prompts.md](docs/starter-prompts.md) shows the bounded-task prompt framing that keeps local models productive.

## Troubleshooting

Below is a list of some of the failure modes you may encounter.
- Context truncation.
- Incorrect tool calls.
- Skills failing to trigger.
- Streaming parse errors.
- Chat-template mismatches.

Advice on fixing these issues is provided in [docs/troubleshooting.md](docs/troubleshooting.md)

## Related Projects

- [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server): the tools your agent uses to run, test, and analyze MATLAB code
- [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit): curated skills for MATLAB workflows
- [Simulink Agentic Toolkit](https://github.com/matlab/simulink-agentic-toolkit): curated skills for Simulink&reg; workflows
- [MATLAB AI Agent SDK](https://github.com/matlab/matlab-ai-agent-sdk): create your own agents in MATLAB

## License

The license is available in the [LICENSE](LICENSE.md) file in this GitHub repository.

## Contact

To ask questions, report issues, or request technical support, open an [Issue](../../issues).

----

Copyright 2026 The MathWorks, Inc.

----
