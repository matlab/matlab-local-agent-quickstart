function readings = processReadings(lines)
%PROCESSREADINGS Parse instrument reading lines into a numeric matrix.
%   readings = processReadings(lines) takes a cell array of strings of the
%   form 'ID=<n> VAL=<x> QUAL=<q>' and returns an Nx3 matrix [id, val, qual]
%   containing only rows whose QUAL is 2 or higher.

readings = [];
for i = 1:length(lines)
    line = lines{i};
    if ~isempty(strfind(line, 'ID='))
        idStr = regexp(line, 'ID=(\d+)', 'tokens', 'once');
        valStr = regexp(line, 'VAL=([-\d\.]+)', 'tokens', 'once');
        qualStr = regexp(line, 'QUAL=(\d+)', 'tokens', 'once');
        id = str2num(idStr{1});
        val = str2num(valStr{1});
        qual = str2num(qualStr{1});
        if qual >= 2
            readings = [readings; id, val, qual];
        end
    end
end
end
