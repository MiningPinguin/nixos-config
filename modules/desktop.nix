{ pkgs, user, ... }:
{
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    wacom.enable = true;
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  boot.plymouth.enable = true;

  programs.firefox.enable = true;

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
    kdePackages.ark
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kclock
    kdePackages.kgamma
    kdePackages.konsole
    kdePackages.partitionmanager
    kdePackages.plasma-sdk
    kdePackages.plymouth-kcm

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
