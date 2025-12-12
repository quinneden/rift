{
  lib,
  git,
  gnused,
  replaceVars,
  writeShellApplication,
}:

let
  cargoToml = builtins.fromTOML (lib.readFile ../../Cargo.toml);
  currentVersion = cargoToml.package.version;
  script = replaceVars ./run.sh { inherit currentVersion; };
in

writeShellApplication {
  name = "bump-version";
  runtimeInputs = [
    git
    gnused
  ];
  text = lib.readFile script;
}
