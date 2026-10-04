{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
  let
    # The one interactive user on every machine.
    user = "miningpinguin";

    # Every machine in this repo is x86_64-linux for now. If that ever changes,
    # move the platform into the host directory instead.
    mkHost = name: extraModules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs user; };
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
      d-mk4 = mkHost "d-mk4" [ ];
      l-mk1 = mkHost "l-mk1" [ ];
      s-mk1 = mkHost "s-mk1" [ ];
      s2-mk1 = mkHost "s2-mk1" [ ];
    };
  };
}
