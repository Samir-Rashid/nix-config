# To rebuild:
# sudo nixos-rebuild switch --flake /etc/nixos/#default --impure
{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware = { url = "github:NixOS/nixos-hardware";
	    flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-old, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs-old = nixpkgs-old.legacyPackages.${system};
      inputs.nixpkgs-old.config.allowUnfree = true;
    in
    {
    
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;
          pkgs-old= import nixpkgs-old {
            # Refer to the `system` parameter from
            # the outer scope recursively
            system = system;
            # To use Chrome, we need to allow the
            # installation of non-free softwares.
            config.allowUnfree = true;
  config.segger-jlink.acceptLicense = true;
          };
};
          modules = [ 
            ./configuration.nix
            ./home.nix
            # inputs.home-manager.nixosModules.default
          ];
        };

    };
}
