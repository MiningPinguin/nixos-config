# s2-mk1: network server. Serves the network itself.
{ ... }:
{
  networking.firewall.enable = true;

  # The README only says "network server", so nothing else is wired up yet.
  # Whatever it ends up serving goes here, e.g.
  #   services.adguardhome.enable = true;
  #   services.tailscale.ingressClass = "tailscale";
}
