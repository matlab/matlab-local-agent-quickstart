function metrics = computeMetrics(t, signals)
%COMPUTEMETRICS Per-channel summary metrics for cleaned telemetry.
%   Returns a struct with per-channel RMS, peak, and drift estimate.
nChannels = 3;
if size(signals, 2) ~= nChannels
    error("computeMetrics:badShape", ...
        "Expected an Nx%d signal matrix, got %s.", ...
        nChannels, mat2str(size(signals)));
end
metrics.rms = sqrt(mean(signals.^2, 1));
metrics.peak = max(abs(signals), [], 1);
p = polyfit(t, signals(:, 3), 1);
metrics.driftPerSecond = p(1);
end
