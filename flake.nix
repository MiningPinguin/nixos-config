{
  inputs = {
    # Stable: servers
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unstable: desktop and laptop
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Only used by the desktop/laptop hosts, so they follow unstable.
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };
  };

  outputs = { ... }@inputs:
    let
    # The one interactive user on every machine.
      user = "miningpinguin";

      channels = {
        stable = {
          nixpkgs = inputs.nixpkgs;
          home-manager = inputs.home-manager;
        };
        unstable = {
          nixpkgs = inputs.nixpkgs-unstable;
          home-manager = inputs.home-manager-unstable;
        };
      };

      mkHost = channel: name: channel.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs user; };
        modules = [
          ./hosts/${name}
          channel.home-manager.nixosModules.home-manager
          { networking.hostName = name; }
        ];
      };
    in {
      nixosConfigurations = {
        d-mk4  = mkHost channels.unstable "d-mk4";
        l-mk1  = mkHost channels.unstable "l-mk1";
        s-mk1  = mkHost channels.stable   "s-mk1";
        s2-mk1 = mkHost channels.stable   "s2-mk1";
      };
    };
}