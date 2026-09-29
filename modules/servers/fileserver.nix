# s-mk1: file server. Shares files over the network.
{ ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;
    # Lets the user add shares at runtime with `net usershare` instead of
    # rebuilding the machine.
    usershares.enable = true;

    # A share is a section in smb.conf, e.g.
    #   media = {
    #     path = "/srv/media";
    #     "read only" = "no";
    #     comment = "Media";
    #   };
    # The directory has to exist (systemd.tmpfiles.rules) and be mounted
    # before it shows up.
  };
}
