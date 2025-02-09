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

    rust-overlay = {
      type = "github";
      owner = "oxalica";
      repo = "rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
    rust-overlay,
    devshell,
    ...
  }: let
    perSystem = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs (import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
            rust-overlay.overlays.default
          ];
        }));
  in {
    packages = perSystem (pkgs: {
      somePackage = pkgs.callPackage ./nix/package.nix {
        rev = self.shortRev or "dirty";
        rustPlatform = pkgs.makeRustPlatform {
          cargo = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
          rustc = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
        };
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

        imports = [
          "${devshell}/extra/language/c.nix"
          "${devshell}/extra/language/rust.nix"
        ];

        language.c = rec {
          libraries = [
            # ...
          ];
          includes = libraries;
        };

        packages =
          (attrValues {
            inherit
              (pkgs)
              pkg-config
              rust-analyzer
              ;
          })
          ++ mainPackage.buildInputs;
      };
    });
  };
}
