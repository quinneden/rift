{
  description = "a tiling window manager for macos";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    naersk.url = "github:nix-community/naersk";
  };

  outputs =
    {
      naersk,
      nixpkgs,
      self,
    }:
    let
      inherit (nixpkgs) lib;
      _lib = import ./nix/lib { inherit lib; };

      systems = lib.systems.doubles.darwin;
      forEachSystem = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      homeModules = {
        default = self.homeModules.rift;
        rift = import ./nix/module { inherit _lib self; };
      };

      packages = forEachSystem (pkgs: {
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.rift;
        bump-version = pkgs.callPackage ./nix/bump-version { };
        rift =
          let
            naersk' = pkgs.callPackage naersk { };
          in
          naersk'.buildPackage { src = self; };
      });

      formatter = forEachSystem (pkgs: pkgs.nixfmt);
    };
}
