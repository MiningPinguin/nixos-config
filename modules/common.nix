{
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";
  i18n.defaultLocale = "en_US.UTF-8";

  # Needed for Discord, Spotify, Steam, Google Chrome, ...
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "wheel" ];

    # Low-disk safety net in case the weekly GC timer is ever missed.
    # Triggers a GC during a build once free space drops below 5G.
    min-free = 5 * 1024 * 1024 * 1024;
    max-free = 10 * 1024 * 1024 * 1024;

    # Deduplicate identical files across store paths to save disk space.
    auto-optimise-store = true;
  };

  security.sudo.wheelNeedsPassword = true;
  users.mutableUsers = true;

  services.tailscale.enable = true;

  # Weekly cleanup of old generations and unused store paths
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # Shorter names in boot menus
  system.nixos.label = "26.05";

  # Compressed swap in RAM, courtesy of the zram-generator service.
  zramSwap.enable = true;
}
