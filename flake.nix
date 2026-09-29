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
    mkHost = name: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/${name}
        home-manager.nixosModules.home-manager
        { networking.hostName = name; }
      ];
    };
  in {
    nixosConfigurations.d-mk1 = mkHost "d-mk1";
  };
}
