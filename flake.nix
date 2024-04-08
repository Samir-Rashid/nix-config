# To rebuild:
# sudo nixos-rebuild switch --flake /etc/nixos/#default
# To check without building:
# nix flake check flake.nix
{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # NOTE: you have to specify branches on urls, otherwise it fails miserably with a cryptic error
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      # flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-old, nix-index-database, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs-old = nixpkgs-old.legacyPackages.${system};
      #inputs.nixpkgs-old.config.allowUnfree = true;
# NOTE: you can't do things like this, otherwise inputs gets overwritten and you will get attribute not available
# something about specialArgs and inputs
# need to reproduce and write blog post
# error: attribute 'inputs' missing
# nix flake attribute nixpkgs missing
# https://discourse.nixos.org/t/flakes-error-error-attribute-outpath-missing/18044
    in
    {

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs-old = import nixpkgs-old {
            # Refer to the `system` parameter from
            # the outer scope recursively
            system = system;
            # To use Chrome, we need to allow the
            # installation of non-free softwares.
            config.allowUnfree = true;
            config.segger-jlink.acceptLicense = true;
          };
          #bruh = builtins.trace "The value of someValue is: inputs" inputs;
          somethingTemporary = builtins.trace (builtins.attrNames inputs) inputs;
        };
        modules = [
          ./configuration.nix
          # hardware stuff
          inputs.nixos-hardware.nixosModules.apple-t2
          inputs.nixos-hardware.nixosModules.common-cpu-intel
          inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
          # TODO: this is nixos-hardware/apple is not in the flake, need to add it

          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users = {
              "samir" = import ./home.nix;
              #root = import ./root-home.nix;
            };
          }
        ];
      };

    };
}
