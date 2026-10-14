classdef tModernize < matlab.unittest.TestCase
    %TMODERNIZE Safety net for the modernize demo: behavior must not change.

    methods (TestClassSetup)
        function addDemoFolderToPath(testCase)
            % The functions under test live one folder up from tests/.
            demoFolder = fullfile(fileparts(mfilename("fullpath")), "..");
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(demoFolder));
        end
    end

    methods (Test)
        function parsesAndFiltersByQuality(testCase)
            lines = {'ID=3 VAL=1.50 QUAL=3', 'ID=1 VAL=-2.25 QUAL=1', ...
                     'ID=2 VAL=0.75 QUAL=2', '# comment line'};
            readings = processReadings(lines);
            testCase.verifyEqual(readings, [3, 1.5, 3; 2, 0.75, 2]);
        end

        function emptyInputGivesEmptyOutput(testCase)
            testCase.verifyEmpty(processReadings({}));
        end

        function summarizesPerSensor(testCase)
            readings = [2, 1.0, 3; 1, 4.0, 2; 2, 3.0, 2];
            summary = summarizeReadings(readings);
            testCase.verifyEqual([summary.id], [1 2]);
            testCase.verifyEqual([summary.meanValue], [4.0 2.0]);
        end
    end
end
