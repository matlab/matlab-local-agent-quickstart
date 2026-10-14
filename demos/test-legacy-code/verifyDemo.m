function verifyDemo()
%VERIFYDEMO Check the Test the Legacy Code demo outcome.
%   Passes when (1) generated tests exist in tests/, (2) the convertPressure
%   and parseLogEntry suites pass, and (3) the mutation check works: the
%   same tests fail when the seeded mutant shadows the real convertPressure.
%   (The windowedStats tests are allowed to fail: they document a real
%   discrepancy between the help text and the implementation.)

if ~isfolder("tests")
    fprintf("verifyDemo: FAIL - no tests/ folder found. Run the demo prompt first.\n");
    return
end

% runtests changes folder into tests/ while running, so put the functions
% under test on the path for the duration of the checks.
restoreFns = onCleanup(@() rmpath(pwd));
addpath(pwd);

% 1) Run the generated tests against the real implementations.
results = runtests("tests", IncludeSubfolders=false);
disp(table(results));
nonWindowed = results(~contains({results.Name}, "windowedStats", IgnoreCase=true));
if isempty(nonWindowed) || ~all([nonWindowed.Passed])
    fprintf("verifyDemo: FAIL - tests for convertPressure/parseLogEntry do not pass.\n");
    return
end

% 2) Mutation check: swap the seeded mutant in for the real convertPressure
%    on disk, rerun the same tests, then restore. A file swap is immune to
%    path-order effects from fixtures inside the generated tests. A test
%    counts as catching the mutant only if it passed on the real code and
%    fails on the mutant; pre-existing failures (the windowedStats
%    discrepancy) do not count.
realFile = fullfile(pwd, "convertPressure.m");
backupFile = fullfile(tempdir, "convertPressure_real_backup.m");
copyfile(realFile, backupFile);
restoreReal = onCleanup(@() restoreAndRehash(backupFile, realFile));
copyfile(fullfile(pwd, "mutants", "convertPressure.m"), realFile);
rehash;
mutantResults = runtests("tests", IncludeSubfolders=false);
clear restoreReal

passedBaseline = string({results([results.Passed]).Name});
failedOnMutant = string({mutantResults([mutantResults.Failed]).Name});
mutantCaught = ~isempty(intersect(passedBaseline, failedOnMutant));
if mutantCaught
    fprintf("verifyDemo: PASS - suites pass on real code, and the seeded mutant\n");
    fprintf("is caught. The tests have teeth.\n");
else
    fprintf("verifyDemo: FAIL - the seeded mutant passed every test. The suite\n");
    fprintf("is not sensitive enough to catch a wrong constant; add value checks.\n");
end
end

function restoreAndRehash(backupFile, realFile)
copyfile(backupFile, realFile);
delete(backupFile);
rehash;
end
