# s-mk1: headless file server.
{ lib, ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/user.nix
    ../../modules/tools.nix
    ../../modules/servers/base.nix
    ../../modules/servers/fileserver.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # Not installed yet, so the bootloader is whatever the installer picks.
  system.stateVersion = "26.05"; # set to the release s-mk1 is installed on
}
