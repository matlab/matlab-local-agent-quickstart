function stats = windowedStats(x, windowLength)
%WINDOWEDSTATS Mean and standard deviation over consecutive windows.
%   stats = windowedStats(x, windowLength) splits the vector X into
%   consecutive non-overlapping windows of WINDOWLENGTH samples and returns
%   a struct array with fields mean and std, one element per window. A
%   final partial window (when numel(x) is not a multiple of windowLength)
%   is included and computed over the remaining samples.

x = x(:);
n = numel(x);
nWindows = floor(n / windowLength);   % drops the trailing partial window
stats = struct("mean", cell(1, nWindows), "std", cell(1, nWindows));
for k = 1:nWindows
    seg = x((k-1)*windowLength + 1 : k*windowLength);
    stats(k).mean = mean(seg);
    stats(k).std = std(seg);
end
end
