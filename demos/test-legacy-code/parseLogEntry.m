function entry = parseLogEntry(line)
%PARSELOGENTRY Parse one line of an instrument log.
%   entry = parseLogEntry(line) parses a log line of the form
%       "2026-07-08 14:03:22 | SENSOR3 | 45.20"
%   and returns a struct with fields timestamp (datetime), sensor (string),
%   and value (double). Raises parseLogEntry:badFormat for malformed lines.

parts = split(string(line), "|");
if numel(parts) ~= 3
    error("parseLogEntry:badFormat", "Expected 3 fields separated by |.");
end
entry.timestamp = datetime(strtrim(parts(1)), ...
    InputFormat="yyyy-MM-dd HH:mm:ss");
entry.sensor = strtrim(parts(2));
entry.value = str2double(parts(3));
if isnan(entry.value)
    error("parseLogEntry:badFormat", "Value field is not numeric.");
end
end
