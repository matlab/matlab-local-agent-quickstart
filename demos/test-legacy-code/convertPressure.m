function out = convertPressure(value, fromUnit, toUnit)
%CONVERTPRESSURE Convert pressure values between psi, kPa, and bar.
%   out = convertPressure(value, fromUnit, toUnit) converts VALUE (scalar
%   or array) from FROMUNIT to TOUNIT. Units: "psi", "kPa", "bar".
%   Conversion is exact through an intermediate kPa representation.

toKPa = containers.Map(["psi","kPa","bar"], [6.894757, 1, 100]);
if ~isKey(toKPa, fromUnit) || ~isKey(toKPa, toUnit)
    error("convertPressure:badUnit", "Units must be psi, kPa, or bar.");
end
out = value * toKPa(fromUnit) / toKPa(toUnit);
end
