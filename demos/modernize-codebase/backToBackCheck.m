function result = backToBackCheck(originalFcn, modifiedFcn, inputs, options)
%BACKTOBACKCHECK Prove modified code produces the original code's outputs.
%   result = backToBackCheck(originalFcn, modifiedFcn, inputs) calls both
%   function handles with each input set in the cell array INPUTS and
%   compares the outputs. It returns a struct with a pass/fail verdict and
%   per-case details.
%
%   result = backToBackCheck(..., Tolerance=1e-10) compares numeric outputs
%   with a relative tolerance instead of exact equality.
%
%   This is the trust primitive of the Quickstart: after an agent modifies
%   your code (modernization, vectorization, refactoring), run the original
%   and the modified version back to back on representative inputs. "The
%   agent changed my code" becomes "the agent changed my code and I can
%   prove it still does the same thing."
%
%   Example:
%       inputs = {{x1}, {x2}, {x3}};   % three test cases
%       r = backToBackCheck(@originalSolver, @newSolver, inputs);
%       assert(r.pass)

arguments
    originalFcn (1,1) function_handle
    modifiedFcn (1,1) function_handle
    inputs cell
    options.Tolerance (1,1) double {mustBeNonnegative} = 0
end

% An empty input set would compare nothing and still report pass, because
% all([]) is true. Refuse it: a silent PASS on unverified code is the exact
% failure this function exists to prevent.
if isempty(inputs)
    error("backToBackCheck:noInputs", ...
        "inputs is empty; there is nothing to verify.");
end

nCases = numel(inputs);
caseResults = struct("index", {}, "match", {}, "detail", {});

for k = 1:nCases
    args = inputs{k};
    if ~iscell(args)
        args = {args};
    end
    outOriginal = originalFcn(args{:});
    outModified = modifiedFcn(args{:});
    [match, detail] = compareOutputs(outOriginal, outModified, options.Tolerance);
    caseResults(k) = struct("index", k, "match", match, "detail", detail);
end

result.pass = all([caseResults.match]);
result.cases = caseResults;
result.tolerance = options.Tolerance;

if result.pass
    fprintf("backToBackCheck: PASS - %d of %d cases produce equivalent outputs.\n", ...
        nCases, nCases);
else
    failed = find(~[caseResults.match]);
    fprintf("backToBackCheck: FAIL - case(s) %s differ.\n", mat2str(failed));
    for k = failed
        fprintf("  case %d: %s\n", k, caseResults(k).detail);
    end
end
end

function [match, detail] = compareOutputs(a, b, tol)
detail = "outputs equivalent";
if isnumeric(a) && isnumeric(b)
    if ~isequal(size(a), size(b))
        match = false;
        detail = sprintf("size mismatch: %s vs %s", mat2str(size(a)), mat2str(size(b)));
        return
    end
    if tol > 0
        denom = max(abs(a(:)), 1);
        maxRel = max(abs(a(:) - b(:)) ./ denom);
        match = maxRel <= tol;
        if ~match
            detail = sprintf("max relative difference %.3g exceeds tolerance %.3g", maxRel, tol);
        end
    else
        match = isequaln(a, b);
        if ~match
            detail = "numeric outputs are not identical (consider a tolerance)";
        end
    end
else
    match = isequaln(a, b);
    if ~match
        detail = "non-numeric outputs differ";
    end
end
end
