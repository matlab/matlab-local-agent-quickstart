function [t, signals] = loadTelemetry(filename)
%LOADTELEMETRY Read a telemetry CSV into a time vector and signal matrix.
T = readtable(filename);
t = T.time;
signals = [T.ch1, T.ch2, T.ch3];
end
