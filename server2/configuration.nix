{ pkgs, ... }:

# TODO : need to figure out perms a much better way :/

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ../shared/legacy-graphics.nix
    ./backup.nix
    ./mounts.nix
    ./jellyfin.nix
    ./qbittorrent.nix
    ./prometheus.nix
    ./navidrome.nix
    ./kiwix.nix
    ./arr.nix
    ./vpn.nix
    ./bridges.nix
  ];

  my.system = {
    user = "admin";

    network = {
      hostname = "server2";
      enableSSH = true;
      privateInterface = "nb-wt0";
    };

    tuning = {
      enable = true;
      arch = "skylake";
      tune = "skylake";
    };

    cache.enable = true;
    netbird.enable = true;
    exporters.enable = true;

    packageSets = [ "util" ];
  };

  # mmmm groups
  users.users.admin.extraGroups = [
    "wheel"
    "jellyfin"
    "kiwix"
    "radarr"
    "sonarr"
    "arr"
    "qbittorrent"
    "media"
  ];

  environment.systemPackages = with pkgs; [
    prometheus-qbittorrent-exporter
    kiwix-tools
  ];

  system.stateVersion = "26.05";
}
