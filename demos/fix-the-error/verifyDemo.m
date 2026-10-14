function verifyDemo()
%VERIFYDEMO Check the Fix the Error demo outcome.
%   Passes when the pipeline runs without error and produces metrics with
%   the correct shape and plausible values.

if ~isfile("telemetry.csv")
    makeTelemetryData();
end

try
    evalc("runPipeline");
catch err
    fprintf("verifyDemo: FAIL - pipeline still errors:\n  %s\n", err.message);
    return
end

[t, signals] = loadTelemetry("telemetry.csv");
[t, signals] = cleanSignals(t, signals);
metrics = computeMetrics(t, signals);

ok = isequal(size(metrics.rms), [1 3]) && ...
     all(metrics.rms > 0) && ...
     abs(metrics.rms(1) - 2.0/sqrt(2)) < 0.1;   % ch1 is a 2.0-amplitude sine

if ok
    fprintf("verifyDemo: PASS - pipeline completes, metrics have the right shape and values.\n");
else
    fprintf("verifyDemo: FAIL - pipeline runs but metrics look wrong: rms = %s\n", ...
        mat2str(metrics.rms, 4));
end
end
