# The graphical desktop: X11, Plasma 6, audio and the applications that go
# with it. Used by d-mk4 and l-mk1.
{ pkgs, user, ... }:
{
  # Session
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    wacom.enable = true; # xf86-input-wacom plus the Plasma wacomtablet settings
  };
  services.displayManager.sddm.enable = true;
  # Plasma pulls in plasma-workspace, kwin-x11, plasma-nm (with NetworkManager),
  # breeze and friends, so none of those need to be listed again here.
  services.desktopManager.plasma6.enable = true;

  # Splash screen. The theme is set in modules/theme/.
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
    #gst-libav
    #gst-plugins-good

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
