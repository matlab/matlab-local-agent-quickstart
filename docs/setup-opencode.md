# Set Up OpenCode

OpenCode is the default harness in this Quickstart. 

It natively supports OpenAI-compatible local endpoints, carries the lightest system-prompt overhead of the three harnesses (freeing more context for use in actual work) and configures from a single JSON file.

## Install

For simplicity, installing OpenCode CLI via the binary directly is recommended.

To do this, download the latest release for your OS and architecture at https://github.com/anomalyco/opencode/releases.

For example, if you have a Windows machine running on x64 architecture, download 
`opencode-windows-x64.zip`.

To install, unzip the binary from the download and place it in whichever directory you would like to run it from. 

You can opt to save the binary in a separate location to your work and add it to your PATH environment variable so that it can be easily invoked in your project directories. If you decide to follow this route, you can find instructions on how to manage global vs. project level config files [here](https://opencode.ai/v2/docs/config).

Further instructions, including alternate installation methods if desired/required, can be found at https://opencode.ai/v2/docs.

## Configure the local provider and the MATLAB MCP Server

Download the MATLAB MCP Server binary and note its path: [setup-matlab-mcp-server.md](setup-matlab-mcp-server.md).

Copy the template for your runtime and platform from [setup/configs/opencode/](../setup/configs/opencode/) into the folder where you will run the agent, renamed to `opencode.json`. For the demos, put it at the repo root so every demo folder inherits it.

After copying a template from [setup/configs/opencode/](../setup/configs/opencode/), you must update some of the values in order to get OpenCode working with your specific setup:

1. **The MCP server path.** Every template shows the standard location with `yourname` in it (`/Users/yourname/.matlab/agentic-toolkits/bin/` on macOS, `C:\Users\yourname\.matlab\agentic-toolkits\bin\` on Windows, `/home/yourname/.matlab/agentic-toolkits/bin/` on Linux). Replace `yourname` with your username, or point at wherever you placed the binary. Use absolute paths on every platform; `~` does not expand when a harness launches the server.
2. **The model identifier** (LM Studio and llama.cpp templates use `local-coder`). Replace it with the model id your runtime reports: LM Studio shows it in the server view, and `curl http://localhost:1234/v1/models` or `:8080/v1/models` lists it. The Ollama templates already match the names the Modelfiles create.

The template, once configured, does two things:

1. Registers your local endpoint (Ollama `:11434`, LM Studio `:1234`, or llama.cpp `:8080`) as the model provider in OpenCode, with the hosted model name.
2. Registers the [MATLAB MCP Server](https://github.com/matlab/matlab-mcp-server) so the agent can run, test, and analyze MATLAB code. Adjust the `command` path to where you placed the binary; use a full absolute path on every platform.

## Skills
OpenCode should now be correctly configured, but depending on the tier of local model you are hosting and available context window, you may want to configure skills before beginning to work on MATLAB tasks with your local agent.

Leave MATLAB Agentic Toolkit skills uninstalled on Small tier. On Medium, add one skill group at a time from the [skills catalog](https://github.com/matlab/matlab-agentic-toolkit) for the workflow you are running, and remove groups you are not using. More skills is not better on local models.

## Verify

To test that OpenCode is configured correctly, run it by either running the binary in the desired location from a terminal, or invoking it if it is on your path.

Once it is running, you can ask a simple test query, such as:

```
What version of MATLAB does the MCP server use?
```

You should see the model performing some reasoning, using tool calls to the MATLAB MCP Server, and then producing a final correct response.

If you get a correct answer from the test query above, you can return to [the main README](../README.md) and continue to the `verifySetup` part of Step 2.
