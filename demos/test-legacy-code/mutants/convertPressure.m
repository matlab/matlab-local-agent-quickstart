function out = convertPressure(value, fromUnit, toUnit)
%CONVERTPRESSURE Seeded mutant for the mutation check. Do not fix this file.
%   Identical to the real convertPressure except for one wrong constant.
%   The generated tests must fail against this version to prove they can
%   catch a real numerical bug.

toKPa = containers.Map(["psi","kPa","bar"], [6.594757, 1, 100]);  % wrong psi factor
if ~isKey(toKPa, fromUnit) || ~isKey(toKPa, toUnit)
    error("convertPressure:badUnit", "Units must be psi, kPa, or bar.");
end
out = value * toKPa(fromUnit) / toKPa(toUnit);
end
