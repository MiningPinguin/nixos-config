# l-mk1: laptop, same Plasma desktop and development setup as d-mk4 minus
# the gaming bits.
{ lib, ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/user.nix
    ../../modules/tools.nix
    ../../modules/dev.nix
    ../../modules/desktop.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # Not installed yet, so the bootloader is whatever the installer picks.
  system.stateVersion = "26.05"; # set to the release l-mk1 is installed on
}
