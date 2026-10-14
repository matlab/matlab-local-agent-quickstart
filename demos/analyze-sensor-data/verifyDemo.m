function verifyDemo()
%VERIFYDEMO Check the Analyze the Sensor Data demo outcome.
%   Passes when results.mat contains a detected fault frequency within 2 Hz
%   of the geometry-predicted BPFO, and the report script runs.

expectedBPFO = (9/2) * 30 * (1 - 0.28);   % 97.2 Hz from the rig metadata

if ~isfile("results.mat")
    fprintf("verifyDemo: FAIL - results.mat not found. The agent should save\n");
    fprintf("a variable detectedFaultFrequency to results.mat.\n");
    return
end

S = load("results.mat");
if ~isfield(S, "detectedFaultFrequency")
    fprintf("verifyDemo: FAIL - results.mat has no detectedFaultFrequency variable.\n");
    return
end

detected = S.detectedFaultFrequency;
errHz = abs(detected - expectedBPFO);
fprintf("Detected fault frequency: %.2f Hz\n", detected);
fprintf("Geometry-predicted BPFO:  %.2f Hz\n", expectedBPFO);
fprintf("Difference:               %.2f Hz\n", errHz);

if errHz >= 2
    fprintf("verifyDemo: FAIL - detected frequency is off by %.2f Hz. Common causes:\n", errHz);
    fprintf("analyzing the raw spectrum instead of the envelope, or picking the\n");
    fprintf("shaft frequency (30 Hz) or resonance (~3 kHz) instead of the fault rate.\n");
    return
end

if isfile("bearingReport.m")
    try
        evalc("run('bearingReport.m')");
        fprintf("[ok] bearingReport.m runs\n");
    catch err
        fprintf("verifyDemo: FAIL - bearingReport.m errors: %s\n", err.message);
        return
    end
else
    fprintf("Note: no bearingReport.m found; frequency verified without the report.\n");
end

fprintf("verifyDemo: PASS - fault frequency matches the bearing geometry.\n");
end
