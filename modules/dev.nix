# Development workstation bits: containers, databases, toolchains.
# Used by d-mk4 and l-mk1.
{ lib, pkgs, user, ... }:
{
  imports = [
    ./dev/jetbrains/intellij.nix
    ./dev/vscodium.nix
    ./dev/jetbrains/android-studio.nix
  ];

  # Containers
  virtualisation.docker.enable = true;
  # mkAfter so this appends to the groups from modules/user.nix instead of
  # replacing them.
  users.users.${user}.extraGroups = lib.mkAfter [ "docker" "kvm" ];

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

    # LaTeX, for latex-workshop in VSCodium
    texliveFull

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
      kicad
    ];

    # Shared Android SDK location for both JetBrains IDEs.
    home.sessionVariables = {
      ANDROID_HOME = "/home/${user}/Android/Sdk";
      ANDROID_SDK_ROOT = "/home/${user}/Android/Sdk";
    };
  };
}
