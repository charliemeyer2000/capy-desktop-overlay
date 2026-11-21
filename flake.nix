{
  description = "Capy desktop app — pre-built macOS app bundle for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    versionFiles = builtins.readDir ./versions;
    versionNames =
      builtins.map (f: nixpkgs.lib.removeSuffix ".json" f)
      (builtins.filter (f: nixpkgs.lib.hasSuffix ".json" f)
        (builtins.attrNames versionFiles));
    latestVersion =
      builtins.head
      (builtins.sort (a: b: builtins.compareVersions a b > 0) versionNames);
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) ["capy-desktop"];
      };
      mkCapy = sourcesFile:
        pkgs.callPackage ./package.nix {
          inherit sourcesFile;
        };
      versionedPackages = builtins.listToAttrs (
        builtins.map (version: {
          name = version;
          value = mkCapy ./versions/${version + ".json"};
        })
        versionNames
      );
      latestSourcesFile = ./versions/${latestVersion + ".json"};
    in
      {
        capy-desktop = mkCapy latestSourcesFile;
        default = self.packages.${system}.capy-desktop;
      }
      // versionedPackages);

    overlays.default = _final: prev: {
      capy-desktop = self.packages.${prev.stdenv.hostPlatform.system}.capy-desktop;
    };
  };
}
