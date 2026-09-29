# s2-mk1: headless network server.
{ lib, ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/user.nix
    ../../modules/tools.nix
    ../../modules/servers/base.nix
    ../../modules/servers/network.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # Not installed yet, so the bootloader is whatever the installer picks.
  system.stateVersion = "26.05"; # set to the release s2-mk1 is installed on
}
