# d-mk4 boot: NixOS-managed GRUB with a hand-written Arch entry, newest kernel.
{ pkgs, ... }:
{
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

  boot.kernelPackages = pkgs.linuxPackages_latest;
}