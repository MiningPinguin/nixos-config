# Shared by the headless machines: s-mk1 and s2-mk1.
{ ... }:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
}
