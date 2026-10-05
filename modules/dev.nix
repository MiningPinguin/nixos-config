# Development workstation bits: containers, databases, toolchains.
# Used by d-mk4 and l-mk1.
{ lib, pkgs, user, ... }:
{
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
      android-studio
      godot
      jetbrains-toolbox
      kicad
      llama-cpp-vulkan
    ];

    programs.vscodium = {
      enable = true;
      profiles.default.userSettings."git.autofetch" = true;
    };
  };
}
