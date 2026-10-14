# Set Up llama.cpp

llama.cpp gives you the most control and the fewest moving parts: one binary, one GGUF file, one command. This makes it a good choice for engineers who want transparency.

## Install

Download a release archive from the [llama.cpp releases page](https://github.com/ggml-org/llama.cpp/releases) for your platform (pick the build matching your GPU: CUDA, Metal, or CPU), or build from source. There is no installer: extract the archive and run the llama.cpp binaries from the folder you extract to.

To use the llama.cpp with CUDA, you will also need to download CUDA libraries (`.dll` files on Windows or `.so` files on Linux). The [llama.cpp releases page](https://github.com/ggml-org/llama.cpp/releases) has links for archives containing these CUDA libraries. Download the archive with the CUDA libraries and extract them to the same directory as the llama.cpp binaries.

## Get a model file

Download the GGUF file for your tier's recommended model and quantization from its publisher's page on `huggingface.co`. Note that:
- It's preferable to get the weights from the original publisher of the model
- However, some publishers do not provide quantized versions of their models. In these cases, you will need to get a quantized version of the model from another publisher.

Below are links for downloading models for the different tiers:
- **Small:** Gemma 4 12B QAT: https://huggingface.co/google/gemma-4-12B-it-qat-q4_0-gguf
- **Medium:** Qwen3 Code 30B A3B Instruct: Select the `Q4_K_M` option from https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF 
- **Medium (other options):**
    - Qwen3.8 27B: Select the `Q4_K_M` option from https://huggingface.co/ggml-org/Qwen3.8-27B-GGUF
    - Devstral Small 24B Instruct 2512: Select the `Q4_K_M` option from https://huggingface.co/unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF
    - gpt-oss-20b: Select the `MXP4` option from https://huggingface.co/ggml-org/gpt-oss-20b-GGUF
    - Muse Climmer 30B: Select the `Q4_K_M` option from https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF

## Serve with an explicit context (do not skip)

Copy the command for your tier (see [the main README.md](../README.md)) and change `-m` to the GGUF file you downloaded. Run it from the folder you extracted the archive into, or put that folder on PATH. On Windows, use `llama-server.exe`; the flags are identical.

**Small:**

```
llama-server -m gemma-4-12b-it-q4_0.gguf -c 12288 --alias local-coder --host 127.0.0.1 --port 8080
```

**Medium:**

```
llama-server -m qwen3-coder-30b-a3b-q4_k_m.gguf -c 16384 --alias local-coder --host 127.0.0.1 --port 8080
```

The `-c` flag is the context window. `--alias local-coder` sets the model id the agent configs in [setup/configs/](../setup/configs/) expect; without it, the server reports the GGUF filename as the id. Binding to `127.0.0.1` keeps the server local-only. The endpoint is OpenAI-compatible at `http://localhost:8080/v1`; `curl http://localhost:8080/v1/models` should list `local-coder`.

GGUF filenames vary by publisher; substitute the filename in the commands above with your filename.

## Watch for

- **Chat template mismatch:** if the model produces runaway output or stops mid-sentence, the chat template is wrong. Recent llama.cpp builds read the template from GGUF metadata; if yours misbehaves, pass the correct template explicitly with `--chat-template` or `--chat-template-file`.
- **GPU layer offload:** by default recent builds offload all layers they can. If you run out of VRAM at your tier's context size, reduce `-c` before reducing GPU layers (`-ngl`); context you cannot fit hurts more than speed you lose.
- **Version pinning:** record the build number (`llama-server --version`) when a setup works.
