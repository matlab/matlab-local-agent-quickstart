function makeTelemetryData()
%MAKETELEMETRYDATA Generate the demo telemetry file (deterministic).
%   Writes telemetry.csv: 1000 samples of time plus three sensor channels,
%   with a handful of NaN dropouts, the way field data actually arrives.

rng(42, "twister");
n = 1000;
t = (0:n-1)' * 0.01;
ch1 = 2.0*sin(2*pi*0.5*t) + 0.1*randn(n,1);
ch2 = 0.8*cos(2*pi*1.2*t) + 0.1*randn(n,1);
ch3 = 0.05*t + 0.2*randn(n,1);

% Sensor dropouts: NaNs scattered across channels on a few sample rows.
dropoutRows = randperm(n, 12);
ch1(dropoutRows(1:4)) = NaN;
ch2(dropoutRows(5:8)) = NaN;
ch3(dropoutRows(9:12)) = NaN;

T = table(t, ch1, ch2, ch3, VariableNames=["time","ch1","ch2","ch3"]);
writetable(T, "telemetry.csv");
fprintf("Wrote telemetry.csv (%d samples, 3 channels, %d dropout rows)\n", n, 12);
end
