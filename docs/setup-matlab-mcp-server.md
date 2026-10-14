# Set Up the MATLAB MCP Server

The MATLAB MCP Server is the bridge between your coding agent and MATLAB: it gives the agent tools to run code, run tests, and analyze files in a live MATLAB session. Every harness configuration in this repo points at this binary, so set it up before configuring a harness.

## 1. Download the binary

Download the release for your platform from the [MATLAB MCP Server releases page](https://github.com/matlab/matlab-mcp-server/releases/latest):

| Platform | Binary |
|----------|--------|
| Windows x64 | `matlab-mcp-server-windows-x64.exe` |
| macOS Apple silicon | `matlab-mcp-server-macos-arm64` |
| macOS Intel | `matlab-mcp-server-macos-x64` |
| Linux x64 | `matlab-mcp-server-linux-x64` |

On macOS, grant execute permission after download:

```sh
chmod +x ~/Downloads/matlab-mcp-server-macos-arm64
```

## 2. Place it and note the path

Put the binary anywhere you like and note the full path; you will write it into your harness configuration. Our config templates use `~/.matlab/agentic-toolkits/bin/`, the same folder the [MATLAB Agentic Toolkit](https://github.com/matlab/matlab-agentic-toolkit) installer uses, so the two projects share one binary if you use both. Create the folder if it does not exist, or use your own location and adjust the template path.

Write the full absolute path in configs on every platform: `C:\Users\yourname\.matlab\agentic-toolkits\bin\matlab-mcp-server-windows-x64.exe` on Windows, `/Users/yourname/.matlab/agentic-toolkits/bin/matlab-mcp-server-macos-arm64` on macOS. Do not rely on `~` expanding; harnesses launch MCP servers without a shell, so `~` stays literal and the server silently never starts.

## 3. Requirements and behavior

- MATLAB R2021a or later, on the system PATH (or pass `--matlab-root` in the config's args).
- By default the server starts MATLAB when the agent first calls a tool. To connect to a MATLAB session you already have open, run `./matlab-mcp-server --setup-matlab` once, then run `shareMATLABSession()` in that MATLAB; see the [server documentation](https://github.com/matlab/matlab-mcp-server) for session modes.
- The server sends anonymized usage telemetry to MathWorks by default. Every config template in this repo passes `--disable-telemetry=true` to keep the stack fully local.
- Licensing: the MCP server must not be shared by multiple users.

## 4. Quick check

Run the binary with `--version` from a terminal. If it prints a version, the binary is good; the end-to-end check comes after harness configuration with `verifySetup` and the "What version of MATLAB is running?" round trip.
