# The shared desktop: X, audio, Bluetooth, Flatpak and the graphical apps.
#
# services.xserver.enable is also what turns hardware.graphics on. nixpkgs does
# that in services.graphical-desktop, with mkDefault, for any host with an X
# server or a display manager. Nothing here sets it, and nothing should have to.
#
# Two things need it and would fail without a word of complaint: Wine loses its
# 32-bit drivers (modules/gaming.nix), and the llama-swap Vulkan drivers stop
# loading on d-mk4. If either breaks, read
# nixos/modules/services/misc/graphical-desktop.nix first, then set
# hardware.graphics.enable = true here.
{ pkgs, user, ... }:
{
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    wacom.enable = true;
  };

  boot.plymouth.enable = true;

  # Printing
  services.printing.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth: pulls in bluez, so bluetoothctl and btmon are around too
  hardware.bluetooth.enable = true;

  # Wi-Fi
  networking.networkmanager.wifi.backend = "iwd";

  # Flatpak, and with it the Plasma flatpak settings
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    # Remote desktop, file dialogs and media playback
    gvfs
    remmina
    yad

    # CJK fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];

  # Proprietary and user-facing applications.
  home-manager.users.${user}.home.packages = with pkgs; [
    discord
    firefox
    google-chrome
    jellyfin-desktop
    spotify
  ];
}
