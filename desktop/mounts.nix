{ ... }:

{
  fileSystems."/home/joey/repos" = {
    device = "/dev/disk/by-uuid/30be04c0-d3a7-4603-84f7-04cf71803032";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "compress=zstd"
      "discard=async"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/22e2db73-0241-4725-9901-8dd5c5e08e57";
    fsType = "btrfs";
    options = [
      "defaults"
      "nofail"
      "noatime"
      "compress=zstd"
      "discard=async"
    ];
  };
}
