# Development workstation bits: containers, databases, toolchains.
# Used by d-mk4 and l-mk1.
{ config, lib, pkgs, user, ... }:
{
  imports = [ ./dev/intellij.nix ];

  # Containers
  virtualisation.docker.enable = true;
  # mkAfter so this appends to the groups from modules/user.nix instead of
  # replacing them.
  users.users.${user}.extraGroups = lib.mkAfter [ "docker" ];

  # Databases
  services.postgresql.enable = true;

  # Toolchains. `npm` and friends come bundled with nodejs.
  environment.systemPackages = with pkgs; [
    docker-compose
    cmake
    jdk
    maven
    ninja
    nodejs
    pnpm
    mutt
    opencode

    # Nix language server and formatter
    nixd
    nixfmt

    # SDK headers, for building against Vulkan and SPIR-V
    vulkan-headers
    spirv-headers

    # Qt 5 modules, still needed by parts of the toolchain
    qt5.qtdeclarative
    qt5.qtwebchannel
    qt5.qtwebsockets

    # Build helper for KDE software
    kdePackages.extra-cmake-modules
  ];

  home-manager.users.${user} = {
    home.packages = with pkgs; [
      # No plugins: addPlugins cannot inject into it, NixOS/nixpkgs#479647
      android-studio
      godot
      kicad
      llama-cpp-vulkan
    ];

    programs.vscodium = {
      enable = true;
      profiles.default = {
        userSettings = {
          "git.autofetch" = true;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.serverSettings".nixd = {
            formatting.command = [ "nixfmt" ];
            options = {
              nixos.expr = ''
                (builtins.getFlake "/home/${user}/nixos-config")
                  .nixosConfigurations.${config.networking.hostName}.options
              '';
              home-manager.expr = ''
                (builtins.getFlake "/home/${user}/nixos-config")
                  .nixosConfigurations.${config.networking.hostName}
                  .options.home-manager.users.type.getSubOptions []
              '';
            };
          };
        };
      };
    };
  };
}
