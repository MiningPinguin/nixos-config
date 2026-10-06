{
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  # Needed for Discord, Spotify, Steam, Google Chrome, ...
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "wheel" ];
  };

  security.sudo.wheelNeedsPassword = true;
  users.mutableUsers = true;

  services.tailscale.enable = true;

  # Weekly cleanup of old generations and unused store paths
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Shorter names in boot menus
  system.nixos.label = "26.05";

  # Compressed swap in RAM, courtesy of the zram-generator service.
  zramSwap.enable = true;
}
