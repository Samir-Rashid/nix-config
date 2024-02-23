{
  description = "home server NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = inputs @ { nixpkgs, home-manager, ... }:
    let
      defaultUser = "backup";

      machines = [
        { name = "envy"; system = "x86_64-linux"; users = [ defaultUser ]; }
        { name = "hopst-pi"; system = "aarch64-linux"; users = [ defaultUser ]; }
      ];

      mkNixosConfig = machine:
        let
          pkgs = import nixpkgs {
            system = machine.system;
            config.allowUnfree = true;
          };
        in
        nixpkgs.lib.nixosSystem {
          modules = [
            inputs.agenix.nixosModules.default
            ({ config, ... }:
              (import ./hosts/${machine.name} { inherit config inputs pkgs; hostname = machine.name; }))
            home-manager.nixosModules.home-manager
            {
              home-manager.users = builtins.listToAttrs (builtins.map
                (username: {
                  name = username;
                  value = import ./hosts/${machine.name}/home/${username} { inherit inputs pkgs username; };
                })
                machine.users);
            }
          ];
        };
    in
    {
      nixosConfigurations = builtins.listToAttrs (builtins.map (machine: { name = machine.name; value = (mkNixosConfig machine); }) machines);
    };
}

