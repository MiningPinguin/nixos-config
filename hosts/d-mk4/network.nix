# d-mk4 network: the NIC has to be re-armed on every boot, after a power cut too.
{
  networking.interfaces.eno1.wakeOnLan.enable = true;

  # Shell and the model tunnel come in over the tailnet, never the LAN.
  services.openssh = {
    enable = true;
    openFirewall = false;
  };
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];
}
