%RUNPIPELINE Process telemetry.csv end to end and report channel metrics.
[t, signals] = loadTelemetry("telemetry.csv");
[t, signals] = cleanSignals(t, signals);
metrics = computeMetrics(t, signals);

fprintf("Channel RMS:   %s\n", mat2str(metrics.rms, 4));
fprintf("Channel peaks: %s\n", mat2str(metrics.peak, 4));
fprintf("Ch3 drift:     %.4f units/s\n", metrics.driftPerSecond);
