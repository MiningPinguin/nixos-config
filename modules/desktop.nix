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
    google-chrome
    jellyfin-desktop
    spotify
  ];
}
