function verifyDemo()
%VERIFYDEMO Check the Modernize the Codebase demo outcome.
%   Three checks: zero Code Analyzer issues, green tests, and back-to-back
%   output equivalence against the untouched copies in original/.

files = ["processReadings.m", "summarizeReadings.m"];

% 1) Code Analyzer clean.
issues = [checkcode(files(1)); checkcode(files(2))];
if ~isempty(issues)
    fprintf("verifyDemo: FAIL - %d Code Analyzer issue(s) remain:\n", numel(issues));
    for k = 1:numel(issues)
        fprintf("  %s\n", issues(k).message);
    end
    return
end
fprintf("[ok] Code Analyzer: zero issues\n");

% 2) Safety-net tests green.
results = runtests("tests");
if ~all([results.Passed])
    fprintf("verifyDemo: FAIL - behavior changed; the test suite no longer passes.\n");
    return
end
fprintf("[ok] Tests: %d passed\n", numel(results));

% 3) Back-to-back equivalence against the untouched originals.
lines = {'ID=3 VAL=1.50 QUAL=3', 'ID=1 VAL=-2.25 QUAL=1', ...
         'ID=2 VAL=0.75 QUAL=2', 'ID=1 VAL=9.00 QUAL=4'};
readings = [2, 1.0, 3; 1, 4.0, 2; 2, 3.0, 2; 1, 6.0, 3];

% Function handles bind to the implementation visible where they are
% created, so capture the original versions while inside original/.
demoDir = pwd;
cd(fullfile(demoDir, "original"));
processOrig = @processReadings;
summarizeOrig = @summarizeReadings;
cd(demoDir);

r1 = backToBackCheck(processOrig, @processReadings, {{lines}});
r2 = backToBackCheck(summarizeOrig, @summarizeReadings, {{readings}});

if r1.pass && r2.pass
    fprintf("verifyDemo: PASS - warnings cleared, tests green, outputs equivalent.\n");
else
    fprintf("verifyDemo: FAIL - modernized code produces different outputs.\n");
end
end
