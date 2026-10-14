function generateBearingData()
%GENERATEBEARINGDATA Synthesize bearing test-rig vibration data (deterministic).
%   Writes bearing_vibration.csv: 8 seconds of accelerometer data at
%   12,800 Hz from a rig with an outer-race bearing defect. Each ball pass
%   over the defect excites a structural resonance; the ball pass rate is
%   the fault signature the analysis should recover.
%
%   Rig: shaft 1800 rpm (30 Hz), 9 rolling elements, d/D = 0.28, contact
%   angle 0. BPFO = (9/2) * 30 * (1 - 0.28) = 97.2 Hz.

rng(2026, "twister");

fs = 12800;
duration = 8;
t = (0:1/fs:duration - 1/fs)';
n = numel(t);

shaftHz = 30;
bpfo = (9/2) * shaftHz * (1 - 0.28);     % 97.2 Hz
resonanceHz = 3000;                       % structural resonance the impacts ring
decay = 800;                              % impact ring-down rate (1/s)

% Impact train at the ball pass rate, with slight jitter as in real rigs.
impactTimes = 1/bpfo : 1/bpfo : duration;
impactTimes = impactTimes + 0.0002*randn(size(impactTimes));
x = zeros(n, 1);
for tk = impactTimes
    idx = t >= tk;
    tau = t(idx) - tk;
    x(idx) = x(idx) + exp(-decay*tau) .* sin(2*pi*resonanceHz*tau);
end

% Shaft imbalance, its harmonic, and broadband noise complete the picture.
x = 0.8*x ...
    + 0.5*sin(2*pi*shaftHz*t) ...
    + 0.2*sin(2*pi*2*shaftHz*t + 0.7) ...
    + 0.25*randn(n, 1);

T = table(t, x, VariableNames=["time", "accel"]);
writetable(T, "bearing_vibration.csv");
fprintf("Wrote bearing_vibration.csv (%d samples, %.0f Hz, %g s)\n", n, fs, duration);
end
