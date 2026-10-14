function verifyDemo()
%VERIFYDEMO Check the Make It Fast demo outcome.
%   Passes when the optimized slowAnalysis produces outputs equivalent to
%   baseline/slowAnalysis.m and runs at least 5x faster, measured with
%   timeit.

rng(7, "twister");
x = randn(200000, 1);
x(50000) = 12;   % guarantee at least one anomaly

% Handles bind to the implementation visible where they are created.
demoDir = pwd;
cd(fullfile(demoDir, "baseline"));
baselineFcn = @slowAnalysis;
cd(demoDir);
optimizedFcn = @slowAnalysis;

% Equivalence first: a fast wrong answer is a worse answer. Vectorization
% reorders floating-point sums, so compare with a small tolerance.
refOut = baselineFcn(x);
newOut = optimizedFcn(x);
okMean = maxRelDiff(refOut.mean, newOut.mean) < 1e-9;
okStd = maxRelDiff(refOut.std, newOut.std) < 1e-9;
okAnom = isequal(refOut.anomalies(:), newOut.anomalies(:));
if ~(okMean && okStd && okAnom)
    fprintf("verifyDemo: FAIL - optimized outputs differ from baseline.\n");
    return
end
fprintf("[ok] Outputs equivalent to baseline\n");

% Then speed, measured the right way.
tBaseline = timeit(@() baselineFcn(x));
tOptimized = timeit(@() optimizedFcn(x));
speedup = tBaseline / tOptimized;
fprintf("Baseline:  %.3f s\nOptimized: %.3f s\nSpeedup:   %.1fx\n", ...
    tBaseline, tOptimized, speedup);

if speedup >= 5
    fprintf("verifyDemo: PASS - equivalent outputs, %.1fx faster.\n", speedup);
else
    fprintf("verifyDemo: FAIL - speedup below 5x. Look for remaining loops\n");
    fprintf("and growing arrays.\n");
end
end

function d = maxRelDiff(a, b)
if ~isequal(size(a), size(b))
    d = Inf;
    return
end
d = max(abs(a - b) ./ max(abs(a), 1));
if isempty(d)
    d = 0;
end
end
