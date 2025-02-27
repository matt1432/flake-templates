{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    systems = {
      type = "github";
      owner = "nix-systems";
      repo = "default-linux";
    };

    devshell = {
      type = "github";
      owner = "numtide";
      repo = "devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    devshell,
    ...
  }: let
    perSystem = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs (import nixpkgs {
          inherit system;
          overlays = [devshell.overlays.default];
        }));
  in {
    packages = perSystem (pkgs: {
      somePackage = pkgs.callPackage ./nix/package.nix {
        rev = self.shortRev or "dirty";
      };

      default = self.packages.${pkgs.system}.somePackage;
    });

    formatter = perSystem (pkgs: pkgs.alejandra);

    devShells = perSystem (pkgs: let
      inherit (pkgs.lib) attrValues;

      mainPackage = self.packages.${pkgs.system}.default;
    in {
      default = pkgs.devshell.mkShell {
        inherit (mainPackage) name;

        imports = ["${devshell}/extra/language/c.nix"];

        language.c = rec {
          compiler = pkgs.gcc14;

          libraries = [
            # ...
          ];
          includes = libraries;
        };

        packages =
          (attrValues {
            inherit
              (pkgs)
              clang-tools
              gdb
              pkg-config
              ;
          })
          ++ mainPackage.buildInputs;
      };
    });
  };
}
