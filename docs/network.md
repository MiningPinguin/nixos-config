# Network

## Wake-on-LAN

The desktop's wired NIC is re-armed on every boot, so a powered-off machine can be started from the LAN. The local models are ready once it boots; nothing waits for a login.

The board has to allow wake by PCI-E and must not cut standby power to the NIC, so the firmware's `ErP` option stays disabled. After a power cut the NIC is disarmed until the machine boots once, so that first start is manual.

Send the magic packet with:

```bash
nix shell nixpkgs#wakeonlan -c wakeonlan c8:7f:54:50:f4:f8
```

Check the arm state with:

```bash
sudo ethtool eno1 | grep Wake-on
```

It should say `g`.

## Tailnet SSH

SSH on the desktop is enabled but not opened on the LAN. The firewall allows it only on the tailnet interface, and sshd starts at boot without a login.

The headless hosts get SSH from their shared base module, with root login disabled.

Loopback-only services are reached by forwarding their ports over SSH.
