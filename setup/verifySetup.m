function report = verifySetup(options)
%VERIFYSETUP Verify the local agentic AI stack link by link.
%   report = verifySetup checks each link in the stack from MATLAB's side,
%   names any failing link, and prints the context budget in effect,
%   because silent context truncation is the most common failure in local
%   setups. The returned struct carries every finding programmatically:
%
%       report.links.runtime        runtime endpoint answered
%       report.links.modelLoaded    at least one model is available
%       report.links.toolUseModelAvailable  LM Studio model supports tool use
%       report.models.count         number of models visible to the runtime
%       report.models.toolUseCount  LM Studio models declaring tool_use
%       report.links.mcpBinary      binary exists (when mcpBinary is passed)
%       report.budget               the context-budget arithmetic
%
%   verifySetup(Runtime="ollama")   checks the Ollama endpoint (default)
%   verifySetup(Runtime="lmstudio") checks the LM Studio endpoint
%   verifySetup(Runtime="llamacpp") checks the llama.cpp server endpoint
%
%   verifySetup(..., ContextTokens=12288) budgets your tier's configured
%   context window; checkLocalAI prints the value to use.
%
%   verifySetup(..., McpBinary="C:\path\to\matlab-mcp-server-windows-x64.exe")
%   also confirms the MATLAB MCP Server binary exists at the path your
%   harness configuration uses; a wrong path there otherwise surfaces only
%   as silent tool failures inside the harness.
%
%   verifySetup(..., Port=8081) will confirm the endpoint on a specific
%   port. Use this if you assigned a non-default port number when you setup
%   your runtime.
%
%   The harness-to-model and tool-calling links are exercised from the
%   harness side: ask your agent "What version of MATLAB is running?" after
%   this check passes.
%
%   All checks are local; nothing leaves this machine.

arguments
    options.Runtime (1,:) {mustBeValidRuntime} = []
    options.ContextTokens (1,1) double {mustBePositive} = 16384
    options.McpBinary (1,1) string = ""
    options.Port (1,:) {mustBeValidPort} = []
end

report = struct("runtime", options.Runtime, "links", struct(), ...
    "models", struct("count", 0), "budget", struct());
fprintf("MATLAB Local AI Quickstart - stack verification\n");
fprintf("================================================\n\n");

% Links 1 and 2: the runtime endpoint answers, and a model is available.
% One request establishes both.
if isempty(options.Port)
    endpoints = dictionary( ...
        "ollama",   "http://localhost:11434/v1/models", ...
        "lmstudio", "http://localhost:1234/v1/models", ...
        "llamacpp", "http://localhost:8080/v1/models");
else
    endpoints = dictionary( ...
        "ollama",   "http://localhost:" + string(options.Port) + "/v1/models", ...
        "lmstudio", "http://localhost:" + string(options.Port) + "/v1/models", ...
        "llamacpp", "http://localhost:" + string(options.Port) + "/v1/models");
end

if isempty(options.Runtime)
    urls = endpoints.values()';
else
    urls = endpoints(options.Runtime);
end

runtimeFound = false;
for url = urls
    [models, runtimeFound] = tryAndContactRuntime(url);
    if runtimeFound
        break;
    end
end

if runtimeFound
    try
        report.links.runtime = true;
        fprintf("[ok]   Runtime endpoint (%s)\n", url);
        report.models.count = countModelData(models);
        report.links.modelLoaded = report.models.count > 0;
        if isequal(options.Runtime, "lmstudio")
            report = checkLMStudioModelCapabilities(report);
        elseif report.links.modelLoaded
            fprintf("[ok]   %d model(s) available\n", report.models.count);
        else
            fprintf("[FAIL] Endpoint answers but no model is loaded.\n");
            printNoModelAdvice(options.Runtime);
        end
    catch err
        report = reportFailure(report,url,err.message,options.Runtime);
    end
else
    message = "A runtime was not specified, and no runtimes were found.\n";
    report = reportFailure(report,url,message,options.Runtime);
end

% Link 3: MATLAB itself (trivially true if we are running, but record the
% facts the harness-side check needs).
report.links.matlab = true;
fprintf("[ok]   MATLAB session (%s)\n", matlabRelease.Release);

% Link 4 (optional): the MCP server binary your harness config points at.
if strlength(options.McpBinary) > 0
    report.links.mcpBinary = isfile(options.McpBinary);
    if report.links.mcpBinary
        fprintf("[ok]   MCP server binary found: %s\n", options.McpBinary);
    else
        fprintf("[FAIL] MCP server binary not found: %s\n", options.McpBinary);
        fprintf("       Download it per docs/setup-matlab-mcp-server.md and make\n");
        fprintf("       your harness config's command path match this one.\n");
    end
end

% Context budget: honest arithmetic for the configured window. Estimates,
% clearly labeled; the point is the order of magnitude, not the digit.
report.budget.contextTokens = options.ContextTokens;
report.budget.harnessOverhead = 5000;   % typical OpenCode-class
report.budget.toolSchemas = 1500;       % five MATLAB MCP tool schemas
report.budget.remaining = options.ContextTokens ...
    - report.budget.harnessOverhead - report.budget.toolSchemas;

fprintf("\nContext budget at %d tokens (estimates):\n", report.budget.contextTokens);
fprintf("  Harness system prompt and built-in tools:  ~%d\n", report.budget.harnessOverhead);
fprintf("  MATLAB MCP tool schemas:                   ~%d\n", report.budget.toolSchemas);
fprintf("  Remaining for your code and conversation:  ~%d\n", report.budget.remaining);
if report.budget.remaining < 6000
    fprintf("  Warning: that is a tight budget. Keep tasks to one function or one\n");
    fprintf("  error, start fresh sessions often, and leave skills off.\n");
end

fprintf("\nFrom your harness, complete the loop with:\n");
fprintf('  "What version of MATLAB is running?"\n');
fprintf("A correct answer proves harness, model, tool-calling, and MCP server\n");
fprintf("in one round trip.\n");
end

function mustBeValidRuntime(runtime)
if ~isempty(runtime)
    mustBeScalar(string(runtime));
    mustBeMember(runtime, ["ollama","lmstudio","llamacpp"]);
end
end

function mustBeValidPort(x)
if ~isempty(x)
    mustBeScalar(x);
    mustBeInteger(x);
    mustBeBetween(x, 0, 65535);
end
end

function report = checkLMStudioModelCapabilities(report)
%Check LM Studio-specific metadata for models that declare tool_use.
metadataUrl = "http://localhost:1234/api/v0/models";
try
    metadata = webread(metadataUrl);
    records = modelRecords(metadata);
    report.models.count = numel(records);
    report.models.toolUseCount = countToolUseModels(records);
    report.links.modelLoaded = report.models.count > 0;
    report.links.toolUseModelAvailable = report.models.toolUseCount > 0;
    if report.links.toolUseModelAvailable
        fprintf("[ok]   %d model(s) available (%d supporting tool use)\n", ...
            report.models.count, report.models.toolUseCount);
    elseif report.links.modelLoaded
        fprintf("[FAIL] %d model(s) available (0 supporting tool use)\n", ...
            report.models.count);
        fprintf("       Load or download a model that supports tool use; see docs/setup-lmstudio.md.\n");
    else
        fprintf("[FAIL] Endpoint answers but no model is loaded.\n");
        printNoModelAdvice("lmstudio");
    end
catch err
    report.models.toolUseCount = 0;
    report.links.toolUseModelAvailable = false;
    if report.links.modelLoaded
        fprintf("[FAIL] %d model(s) available, but tool-use support could not be verified.\n", ...
            report.models.count);
        fprintf("       %s\n", err.message);
        fprintf("       Expected metadata endpoint: %s\n", metadataUrl);
        fprintf("       See docs/setup-lmstudio.md.\n");
    else
        fprintf("[FAIL] Endpoint answers but no model is loaded.\n");
        printNoModelAdvice("lmstudio");
    end
end
end

function [models, success] = tryAndContactRuntime(url)
try
    models = webread(url);
    success = true;
catch
    models = struct();
    success = false;
end
end

function count = countModelData(response)
%Return the number of model records in an OpenAI-compatible response.
count = 0;
if isstruct(response) && isfield(response, "data")
    count = numel(response.data);
end
end

function records = modelRecords(response)
%Return model records as a cell array, preserving heterogeneous fields.
records = {};
if ~isstruct(response) || ~isfield(response, "data")
    return
end
data = response.data;
if iscell(data)
    records = data(:);
elseif isstruct(data)
    records = num2cell(data(:));
end
end

function count = countToolUseModels(records)
%Count model records whose capabilities include the LM Studio tool_use flag.
count = 0;
for k = 1:numel(records)
    record = records{k};
    if isstruct(record) && isfield(record, "capabilities") ...
            && hasToolUseCapability(record.capabilities)
        count = count + 1;
    end
end
end

function tf = hasToolUseCapability(capabilities)
%Return true when a capabilities value contains the tool_use token.
tf = false;
if iscell(capabilities)
    for k = 1:numel(capabilities)
        if isTextValue(capabilities{k}) && any(string(capabilities{k}) == "tool_use")
            tf = true;
            return
        end
    end
elseif isTextValue(capabilities)
    tf = any(string(capabilities) == "tool_use");
end
end

function tf = isTextValue(value)
tf = ischar(value) || isstring(value);
end

function report = reportFailure(report,url,message,runtime)
report.links.runtime = false;
report.links.modelLoaded = false;
report.models.count = 0;
if isempty(runtime)
    fprintf("[FAIL] Runtime endpoint\n");
else
    fprintf("[FAIL] Runtime endpoint (%s)\n", url);
end
fprintf("       %s\n", message);
printEndpointFailureAdvice(runtime, url);
end

function printEndpointFailureAdvice(runtime, url)
%Print the first concrete action for a runtime endpoint failure.
if isempty(runtime)
    fprintf("       Run verifySetup and specify the Runtime option as ""ollama"", ""lmstudio"" or ""llamacpp""\n");
    return
end
switch runtime
    case "ollama"
        fprintf("       Start Ollama, then run your tier's model.\n");
        fprintf('       Example: ollama run qwen-coder-16k "Say ready."\n');
        guide = "docs/setup-ollama.md";
    case "lmstudio"
        fprintf("       Start LM Studio, load your tier's model, then open the\n");
        fprintf("       Developer tab and start the local server.\n");
        guide = "docs/setup-lmstudio.md";
    otherwise % "llamacpp"
        fprintf("       Start llama-server with your model file, explicit context,\n");
        fprintf("       --host 127.0.0.1, and --port 8080.\n");
        guide = "docs/setup-llamacpp.md";
end
fprintf("       Expected endpoint: %s\n", url);
fprintf('       See %s, then rerun verifySetup(runtime="%s").\n', guide, runtime);
end

function printNoModelAdvice(runtime)
%Print the first concrete action when the endpoint works but no model is loaded.
switch runtime
    case "ollama"
        fprintf("       Pull or create your tier's model, then run it.\n");
        fprintf("       See docs/setup-ollama.md.\n");
    case "lmstudio"
        fprintf("       Load your tier's model in LM Studio, with the context length\n");
        fprintf("       set to the value from checkLocalAI.\n");
        fprintf("       See docs/setup-lmstudio.md.\n");
    otherwise   % "llamacpp"
        fprintf("       Restart llama-server with the GGUF file for your tier's model.\n");
        fprintf("       See docs/setup-llamacpp.md.\n");
end
end