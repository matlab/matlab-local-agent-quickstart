function features = slowAnalysis(x)
%SLOWANALYSIS Windowed statistics and anomaly detection for a signal.
%   features = slowAnalysis(x) computes, for each 50-sample trailing window
%   over the vector X: the window mean and sample standard deviation. It
%   then flags anomalies where the current sample deviates from its window
%   mean by more than 3 window standard deviations.
%
%   Returns a struct with fields mean, std (one value per full window,
%   starting at sample 50) and anomalies (indices into X).

x = x(:);
n = numel(x);
w = 50;

mu = [];
sd = [];
for k = w:n
    seg = x(k-w+1:k);
    s = 0;
    for j = 1:w
        s = s + seg(j);
    end
    m = s / w;
    ss = 0;
    for j = 1:w
        ss = ss + (seg(j) - m)^2;
    end
    mu = [mu; m];
    sd = [sd; sqrt(ss / (w-1))];
end

anomalies = [];
for k = 1:numel(mu)
    sampleIndex = k + w - 1;
    if abs(x(sampleIndex) - mu(k)) > 3 * sd(k)
        anomalies = [anomalies; sampleIndex];
    end
end

features.mean = mu;
features.std = sd;
features.anomalies = anomalies;
end
