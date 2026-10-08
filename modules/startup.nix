# Apps that come up with the session, in the background rather than in front of
# it. KDE autostart rather than systemd units: these are graphical apps that want
# the session, and Plasma keeps its own bookkeeping for entries written this way,
# the same as the one plasma-manager declares for itself.
#
# KDE Connect is absent here on purpose. programs.kdeconnect.enable in
# modules/plasma.nix already installs its autostart entry, so adding one would
# be the same setting in two places.
{ lib, pkgs, user, ... }:
{
  home-manager.users.${user}.xdg.configFile."autostart/discord.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Discord
    Exec=${lib.getExe pkgs.discord} --start-minimized
    Icon=discord
    Terminal=false
    StartupNotify=false
    X-KDE-autostart-condition=ksmserver
  '';
}
