# d-mk4: desktop with a plasma session, used for development and gaming.
{ lib, pkgs, ... }:
{
  imports = [
    ../../modules/common.nix
    ../../modules/user.nix
    ../../modules/tools.nix
    ../../modules/dev.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/plasma.nix
    ../../modules/theme/catppuccin.nix
  ]
  # The installer drops hardware-configuration.nix in here.
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.timeout = 5;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = false;
    configurationLimit = 6;

    extraEntries = ''
      menuentry "Arch Linux" --class arch --class gnu-linux --class os {
        search --no-floppy --fs-uuid --set=root 678F-2BFB
        linux /vmlinuz-linux root=PARTUUID=03a56500-4cad-4faf-b861-0727992e5397 zswap.enabled=0 rw rootfstype=ext4
        initrd /amd-ucode.img /initramfs-linux.img
      }
    '';
  };

  # Shorter names in the GRUB generation submenu
  system.nixos.label = "26.05";

  # Weekly cleanup of old generations and unused store paths
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Newest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "26.05";
}
