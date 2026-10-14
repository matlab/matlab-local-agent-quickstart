function [t, signals] = cleanSignals(t, signals)
%CLEANSIGNALS Remove samples containing sensor dropouts (NaN values).
badRows = any(isnan(signals), 2);
t(badRows) = [];
signals(badRows) = [];   % removes elements, not rows: collapses the matrix
end
