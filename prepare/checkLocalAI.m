function result = checkLocalAI()
%CHECKLOCALAI Check this machine's readiness for local agentic AI with MATLAB.
%   result = checkLocalAI detects memory, GPU, MATLAB version, and required
%   tools, assigns the machine a hardware tier, and prints the recommended
%   configuration. The returned struct carries everything the display
%   shows, so scripts and tests can consume the findings programmatically:
%
%       result.tier                          "Small" | "Medium" | "BelowSmall"
%       result.tierNote                      one-line honest caveat for this machine
%       result.recommendation.model          recommended model for the tier
%       result.recommendation.contextTokens  value to pass to verifySetup
%
%   This function makes no network calls.

result = struct();

fprintf("MATLAB Local AI Quickstart - readiness check\n");
fprintf("=============================================\n\n");

% --- Platform and MATLAB ---
result.platform = computer;
result.matlabRelease = matlabRelease.Release;
result.livecodeReady = ~isMATLABReleaseOlderThan("R2025a");
fprintf("MATLAB:          %s\n", result.matlabRelease);
if ~result.livecodeReady
    fprintf("                 Note: R2025a or later enables the plain-text Live\n");
    fprintf("                 Script format the sensor-data demo produces.\n");
end

% --- Memory ---
result.memoryGB = detectMemoryGB();
fprintf("System memory:   %.0f GB\n", result.memoryGB);

% --- GPU / accelerator ---
result.isAppleSilicon = ismac && contains(result.platform, "MACA");
[result.gpuName, result.vramGB] = detectGPU();
if result.isAppleSilicon
    result.acceleratorGB = result.memoryGB;   % unified memory feeds the GPU
    fprintf("GPU:             Apple silicon integrated GPU (%.0f GB unified memory)\n", result.memoryGB);
    fprintf("                 Note: base chips have roughly a quarter of the memory\n");
    fprintf("                 bandwidth of Max-class chips; capacity sets what loads,\n");
    fprintf("                 bandwidth sets how fast it generates.\n");
elseif any(result.vramGB > 0)
    result.acceleratorGB = max(result.vramGB);
    if isscalar(result.vramGB)
        fprintf("GPU:             %s (%.0f GB VRAM)\n", result.gpuName(1), result.vramGB(1));
    else
        fprintf("GPU:             Multiple GPUs found. GPU with the largest VRAM will determine tier.\n");
        for i = 1:numel(result.vramGB)
            fprintf("                     %s (%.0f GB VRAM)\n", result.gpuName(i), result.vramGB(i))
        end
    end
else
    result.acceleratorGB = 0;
    fprintf("GPU:             none detected (CPU inference is possible but slow)\n");
end

% --- Companion tools ---
result.hasGit = toolOnPath("git --version");
result.hasNode = toolOnPath("node --version");
fprintf("Git:             %s\n", presentString(result.hasGit));
fprintf("Node.js:         %s (required by some harness installs)\n", presentString(result.hasNode));

% --- Tier assignment and recommendation ---
hasAccelerator = any(result.vramGB > 0) || result.isAppleSilicon;
[result.tier, result.tierNote] = assignTier(result.acceleratorGB, result.memoryGB, hasAccelerator);
result.recommendation = tierRecommendation(result.tier);

fprintf("\nTier: %s\n", result.tier);
if strlength(result.tierNote) > 0
    fprintf("      %s\n", result.tierNote);
end
printRecommendation(result.recommendation);
end

function gb = detectMemoryGB()
%Return total system memory in GB across platforms.
if ispc
    % memory() gives an available-memory floor; CIM gives the true total.
    % (wmic is removed from current Windows builds; use PowerShell CIM.)
    m = memory;
    gb = m.MemAvailableAllArrays / 2^30;
    [status, out] = system("powershell -NoProfile -Command ""(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory""");
    total = str2double(strtrim(out));
    if status == 0 && ~isnan(total)
        gb = total / 2^30;
    end
elseif ismac
    [~, out] = system("sysctl -n hw.memsize");
    gb = str2double(strtrim(out)) / 2^30;
else
    [~, out] = system("grep MemTotal /proc/meminfo | awk '{print $2}'");
    gb = str2double(strtrim(out)) / 2^20;
end
if isnan(gb)
    gb = 0;
end
end

function [name, vramGB] = detectGPU()
%Return GPU name and VRAM in GB, or empty/0 when none is found.
name = "";
vramGB = 0;
% Prefer nvidia-smi so no toolbox is required.
[status, out] = system("nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits");
if status == 0 && ~isempty(strtrim(out))
    out = split(string(out), newline);
    out = out(strlength(strtrim(out)) > 0);
    parts = split(out, ",");
    if size(parts, 2) >= 2
        name = strtrim(parts(:, 1));
        vramGB = str2double(strtrim(parts(:, 2))) / 1024;
        return
    end
end
% Fall back to Parallel Computing Toolbox when present.
if license("test", "Distrib_Computing_Toolbox") && canUseGPU()
    d = gpuDevice;
    name = string(d.Name);
    vramGB = d.TotalMemory / 2^30;
end
end

function tf = toolOnPath(cmd)
[status, ~] = system(cmd);
tf = (status == 0);
end

function s = presentString(tf)
if tf
    s = "found";
else
    s = "not found";
end
end

function [tier, note] = assignTier(acceleratorGB, memoryGB, hasAccelerator)
%Assign the hardware tier from accelerator memory, per the tier table in README.md.
%   Returns the tier as a clean category plus a separate honest caveat, so
%   callers branch on the category and readers get the explanation.
note = "";
if acceleratorGB >= 20
    tier = "Medium";
elseif acceleratorGB >= 10
    tier = "Small";
elseif hasAccelerator && memoryGB >= 32
    tier = "Small";
    note = "Sub-10 GB GPU: the runtime splits the model between GPU and system RAM; expect slower generation.";
elseif memoryGB >= 32
    tier = "Small";
    note = "CPU-only: generation will be slow.";
else
    tier = "BelowSmall";
    note = "Your hardware is not suitable for running a local model; consider a cloud model for now.";
end
end

function rec = tierRecommendation(tier)
%Return the support-matrix row for a tier, per the tier table in README.md.
%   The matrix lives here once; display and tests both read this struct.
switch tier
    case "Medium"
        rec.model = "Qwen3-Coder-30B-A3B (MoE), Q4_K_M";
        rec.contextTokens = 16384;
        rec.contextGuidance = "16384 to 32768";
        rec.harness = "OpenCode";
        rec.skills = "curated, one group at a time";
        rec.notes = "This is the recommended tier for reliable multi-turn agentic work.";
    case "Small"
        rec.model = "Gemma 4 12B QAT, Q4";
        rec.contextTokens = 12288;
        rec.contextGuidance = "8192 to 16384";
        rec.harness = "OpenCode";
        rec.skills = "off (small context windows fill up fast)";
        rec.notes = "Expect assisted, single-step help. Reliable autonomous multi-tool work starts at the Medium tier.";
    otherwise   % BelowSmall
        rec.model = "";
        rec.contextTokens = 0;
        rec.contextGuidance = "";
        rec.harness = "";
        rec.skills = "";
        rec.notes = "Below the Small tier minimum; see the tier table in README.md.";
end
end

function printRecommendation(rec)
if strlength(rec.model) == 0
    fprintf("\n%s\n", rec.notes);
    return
end
fprintf("\nRecommended configuration (see the tier table in README.md):\n");
fprintf("  Model:    %s\n", rec.model);
fprintf("  Context:  %s\n", rec.contextGuidance);
fprintf("  Harness:  %s\n", rec.harness);
fprintf("  Skills:   %s\n", rec.skills);
if strlength(rec.notes) > 0
    fprintf("  %s\n", rec.notes);
end
fprintf("\nNext: follow the setup guides in docs/, then check the stack with\n");
fprintf("  verifySetup(contextTokens=%d)\n", rec.contextTokens);
end
