{ lib, ... }:

with lib;

let
  # TODO: Inefficient (mapping over whole list when not necessary)
  capitalizeString = let specialCases = { htpc = "HTPC"; };
  in str:
  if (hasAttr str specialCases) then
    specialCases.${str}
  else
    concatStrings
    (imap0 (i: l: if i == 0 then (toUpper l) else l) (stringToCharacters str));
in { inherit capitalizeString; }
