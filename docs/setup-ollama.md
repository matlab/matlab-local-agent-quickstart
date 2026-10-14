# Set Up Ollama

Ollama ([ollama.com](https://ollama.com)) is a free program that downloads models and runs them in the background on your own computer, where your coding agent can reach them.

**Why use Ollama:** you get a model running with a few terminal commands, and Ollama keeps it running in the background.

## Install

Download Ollama from [ollama.com](https://ollama.com) and install it.

## Get a model

Pull your tier's recommended model:

- **Small:** `ollama pull gemma4:12b-it-qat`
- **Medium:** `ollama pull qwen3-coder:30b`
- **Medium (other options):**
    - `ollama pull qwen3.8:27b`
    - `ollama pull devstral-small-2:24b`
    - `ollama pull gpt-oss:20b`
    - `ollama pull muse-glimmer:30b`

To find your tier, run `checkLocalAI` in MATLAB or see the tier table in [the main README.md](../README.md).

To use a different model, find it in the [Ollama library](https://ollama.com/library) and pull it by its full name, including the tag after the colon (for example `qwen3-coder:30b`, not `qwen3-coder`).

## Set the context window (do not skip)

Ollama picks a default context window based on your GPU memory (about 4k below 24 GB, 32k from 24 to 48 GB), which is usually much smaller than the model supports. Set it yourself by building a copy of the model with the context window included.

From the root of this repo, run the command for your tier:

**Small:**

```
ollama create gemma-small -f setup/configs/ollama/Modelfile.small
```

**Medium:**

```
ollama create qwen-coder-16k -f setup/configs/ollama/Modelfile.medium
```

Each Modelfile names the model to start from (`FROM`) and sets the context window (`PARAMETER num_ctx`). The name after `ollama create` (`gemma-small` or `qwen-coder-16k`) is the model name you give your agent. If you pulled a different model, copy a Modelfile and change the `FROM` line.

## Check that it's running

Use the model name you just created:

```
ollama run qwen-coder-16k "Say ready."
```

The model should reply. Ollama makes the model available to your agent at `http://localhost:11434/v1`, and by default only your own computer can connect to it. On macOS and Windows, Ollama downloads updates automatically; they apply when you restart it.

The Ollama versions and models these commands were last verified against are in [setup/configs/ollama/VERSIONS.md](../setup/configs/ollama/VERSIONS.md).

## Watch for

- **Slow responses on GPU:** if the model and context do not fit in GPU memory, Ollama runs part of the model on the CPU instead, which is much slower. `ollama ps` shows how the model is split between CPU and GPU. Lower `num_ctx` in the Modelfile (for example, from 16384 to 12288), run `ollama create` again, and retry.
- **Version pinning:** model updates can change how a model behaves. When a setup works, record the model ID (`ollama list`) and the Ollama version (`ollama --version`).
