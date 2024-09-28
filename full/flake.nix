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
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    ...
  }: let
    perSystem = attrs:
      nixpkgs.lib.genAttrs (import systems) (system:
        attrs (import nixpkgs {inherit system;}));
  in {
    nixosModules = {
      someModule = import ./modules self;

      default = self.nixosModules.someModule;
    };

    packages = perSystem (pkgs: {
      somePackage = pkgs.callPackage ./pkgs {};

      default = self.packages.${pkgs.system}.somePackage;
    });

    formatter = perSystem (pkgs: pkgs.alejandra);

    devShells = perSystem (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          # ... more dev packages
        ];
      };
    });
  };
}
