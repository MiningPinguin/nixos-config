# d-mk4 storage: the four partitions of the second NVMe, on /mnt. That disk
# changes name between boots, nvme0n1 or nvme1n1, hence the labels. Mounted at
# boot because an unmounted fstab entry makes Dolphin ask udisks for a password.
# nofail, so a drive that fails to mount cannot stop the boot. ext4 ignores uid
# and gid mount options, ownership is set on the filesystems themselves.
{
  fileSystems."/mnt/games-1" = {
    device = "/dev/disk/by-label/games-1";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };

  fileSystems."/mnt/games-2" = {
    device = "/dev/disk/by-label/games-2";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };

  fileSystems."/mnt/games-3" = {
    device = "/dev/disk/by-label/games-3";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };

  fileSystems."/mnt/extra" = {
    device = "/dev/disk/by-label/extra";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };
}