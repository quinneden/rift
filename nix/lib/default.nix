{ lib }:

let
  recursiveApply =
    op: attrs:
    with lib;
    mapAttrs' (n: v: nameValuePair (op n) (if isAttrs v then recursiveApply op v else v)) attrs;

  toSnakeCase =
    with lib;
    s:
    let
      isUpper = c: match "[A-Z]" c != null;
      chars = stringToCharacters s;
    in
    concatStrings (
      map (
        c:
        if (isUpper c && c != elemAt chars 0) then
          "_" + (toLower c)
        else if c == "-" then
          "_"
        else
          toLower c
      ) chars
    );
in

{
  inherit toSnakeCase recursiveApply;
}
