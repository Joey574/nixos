{ ... }:

{
  boot.swraid.enable = true;
  boot.swraid.mdadmConf = "PROGRAM /run/current-system/sw/bin/true  ";

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/1ffac172-61a1-4d17-9c08-705359dbc157";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  fileSystems."/home/jellyfin/media" = {
    device = "/mnt/storage/jellyfin-media";
    fsType = "none";
    options = [
      "bind"
      "x-systemd.requires=/mnt/storage"
      "nofail"
    ];
  };

  fileSystems."/home/kiwix/data" = {
    device = "/mnt/storage/kiwix-data";
    fsType = "none";
    options = [
      "bind"
      "x-systemd.requires=/mnt/storage"
      "nofail"
    ];
  };
}
