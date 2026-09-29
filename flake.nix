{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    # Every machine in this repo is x86_64-linux for now. If that ever changes,
    # move the platform into the host directory instead.
    mkHost = name: extraModules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/${name}
        home-manager.nixosModules.home-manager
        {
          networking.hostName = name;
        }
      ] ++ extraModules;
    };
  in {
    # A host picks its own modules from its own directory, so adding one-off
    # tweaks here is only needed for things that must apply everywhere.
    nixosConfigurations = {
      d-mk1 = mkHost "d-mk1" [ ];
      l-mk1 = mkHost "l-mk1" [ ];
      s-mk1 = mkHost "s-mk1" [ ];
      s2-mk1 = mkHost "s2-mk1" [ ];
    };
  };
}
