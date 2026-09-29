# Shared by the headless machines: s-mk1 and s2-mk1.
{ ... }:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  # zramSwap itself comes from modules/common.nix.

  services.tailscale.enable = true;
}
