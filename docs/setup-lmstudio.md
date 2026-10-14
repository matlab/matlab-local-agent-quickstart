# Set Up LM Studio

LM Studio ([lmstudio.ai](https://lmstudio.ai)) is a free desktop app that downloads models and runs them on your own computer, where your coding agent can reach them. It runs on macOS, Windows, and Linux.

**Why use LM Studio:** you can download, load, and serve a model from the app window, without using the terminal.

## Install

Download LM Studio from the [LM Studio download page](https://lmstudio.ai/download) and install it. The first time you open it, LM Studio offers to download a model. Skip that, because you pick your tier's model in the next step.

LM Studio also works on computers without a GPU, but responses are much slower. On Windows, your CPU must support AVX2. On a Mac, LM Studio needs Apple silicon; it does not run on Intel Macs.

## Download a model

1. Open the **Model Search** tab.
2. Search for your tier's recommended model. You can also paste a Hugging Face URL into the search bar.
   - **Small:** Gemma 4 12B QAT
   - **Medium:** Qwen3 Coder 30B
   - **Medium (other options):**:
      - Qwen3.8 27B
      - Devstral Small 2 2512
      - GPT-OSS 20B
      - Muse Glimmer 30B
3. Pick a 4-bit quantization such as `Q4_K_M`. If your computer has memory to spare, you can pick a higher one.
4. Click **Download**.

To find your tier, run `checkLocalAI` in MATLAB or see the tier table in [the main README.md](../README.md).

## Load the model and set the context length (do not skip)

1. Open the **Developer** tab (the `>_` icon in the left sidebar). If you don't see it, change the mode selector at the bottom left from **User** to **Power User** or **Developer**.
2. Open the **Local Server** tab inside it.
3. Click **+ Load Model** and choose the model you downloaded.
4. Before the model loads, set the context length for your tier:
   - **Small:** 12288
   - **Medium:** 16384

LM Studio's default context length is smaller than the model supports, and it cuts off text past that length without telling you. This is the most common problem with local setups. If the model fails to load or runs out of memory, lower the context length one step (for example, from 16384 to 12288) before you try a different model.

## Start the server

You can start the server from the app or from a terminal.

- **In the app:** on the **Local Server** tab, turn the server on.
- **From a terminal:** LM Studio comes with the `lms` command, but you have to install it before you can use it. The install command uses `npx`, which comes with [Node.js](https://nodejs.org/en/download), so install Node.js first if you don't have it. Then run:

  ```
  npx lmstudio install-cli
  ```

  Open a new terminal and start the server:

  ```
  lms server start --port 1234
  ```

## Check that it's running

Open `http://localhost:1234/v1/models` in a browser or run `curl http://localhost:1234/v1/models`. You should see the model you loaded. This is the address your coding agent connects to.

The model id in that list is the name you give your agent. The LM Studio agent configs in [setup/configs/](../setup/configs/) use `local-coder`, so change it to match your model id (see [setup-opencode.md](setup-opencode.md)).

## Watch for

- **Context length resets when you reload:** LM Studio applies the context length when it loads a model. If you reload the model, set the context length again.
- **Slow responses on GPU:** if the model and context do not fit in GPU memory, LM Studio runs part of the model on the CPU instead, which is much slower. Lower the context length one step (for example, from 16384 to 12288), reload the model, and try again.
- **Broken tool calls:** if your agent reports malformed tool calls, turn off streaming in your agent's config and try again. See [troubleshooting.md](troubleshooting.md).
