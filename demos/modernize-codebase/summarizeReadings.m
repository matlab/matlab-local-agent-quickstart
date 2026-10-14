function summary = summarizeReadings(readings)
%SUMMARIZEREADINGS Per-sensor mean values from a readings matrix.
%   summary = summarizeReadings(readings) takes the Nx3 matrix from
%   processReadings and returns a struct array with fields id and meanValue,
%   one element per distinct sensor id, in ascending id order.

ids = unique(readings(:,1));
means = [];
count = 0;
for i = 1:length(ids)
    count = count + 1;
    mask = readings(:,1) == ids(i);
    vals = readings(mask, 2);
    m = mean(vals);
    means = [means; m];
end
summary = struct("id", num2cell(ids), "meanValue", num2cell(means));
end
