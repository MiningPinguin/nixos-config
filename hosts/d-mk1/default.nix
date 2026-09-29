# d-mk1: desktop with a plasma session, used for development and gaming.
{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/user.nix
    ../../modules/tools.nix
    ../../modules/dev.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
  ]
  # The installer drops hardware-configuration.nix in here.
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Newest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "26.05";
}
