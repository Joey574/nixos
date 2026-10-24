{
  config,
  lib,
  pkgs,
  ...
}:

# TODO
# love my import script but it really needs to go, need to push everything to the same HDD so I can just use hardlinks
# or just add symlink support to the *arr stack :/

let
  arr-go = pkgs.buildGoModule {
    pname = "arr-go";
    version = "0-unstable";

    src = pkgs.fetchFromGitHub {
      owner = "Joey574";
      repo = "arr-go";
      rev = "761eec31144d11c83b7b0bc84dbcd8fe2ee100ea";

      hash = "sha256-seJbRSeqgDBYnQFyvlVtPOkH8oBtdsybb7mFDOZPkWI=";
    };

    vendorHash = "sha256-ZeUlSWqQrejFMNqgDEfXzExJRL+z0vNPk27HvzHPKhY=";
  };

  iface = config.my.system.network.privateInterface;
in
{
  environment.systemPackages = [ arr-go ];

  networking.firewall.interfaces.${iface}.allowedTCPPorts = [
    5055
    6767
    7878
    8000
    8686
    8989
    9696
  ];

  users.groups.arr = { };
  users.users.arr = {
    isSystemUser = true;
    group = "arr";
  };

  # log file system rules
  systemd.tmpfiles.rules = [
    "d /var/lib/radarr 0750 radarr arr -"
    "d /var/lib/sonarr 0750 sonarr arr -"
    "d /var/lib/bazarr 0750 bazarr arr -"
    "d /var/log/arr 2770 arr arr -"
    "d /etc/arr 0750 arr arr -"
  ];

  system.activationScripts.arrAccess = {
    text = ''
      # allow traversal into qbit's directory
      ${pkgs.acl}/bin/setfacl -m u:radarr:x,u:sonarr:x,u:lidarr:x /var/lib/qBittorrent /var/lib/qBittorrent/qBittorrent

      # allow rwx on download directory
      ${pkgs.acl}/bin/setfacl -d -m u:radarr:rwx,u:sonarr:rwx,u:lidarr:rwx,u:bazarr:rwx /var/lib/qBittorrent/qBittorrent/downloads
      ${pkgs.acl}/bin/setfacl -m u:radarr:rwx,u:sonarr:x,u:lidarr:x,u:bazarr:rwx /var/lib/qBittorrent/qBittorrent/downloads

      # make /etc/arr and /var/log/arr available
      ${pkgs.acl}/bin/setfacl -d -m u:radarr:rwx,u:sonarr:rwx,u:lidarr:rwx,u:bazarr:rwx /var/log/arr
      ${pkgs.acl}/bin/setfacl -m u:radarr:rwx,u:sonarr:rwx,u:lidarr:rwx,u:bazarr:rwx /var/log/arr
      ${pkgs.acl}/bin/setfacl -m u:radarr:rx,u:sonarr:rx,u:lidarr:rx,u:bazarr:rx /etc/arr

      # allow access into jellyfin
      ${pkgs.acl}/bin/setfacl -m u:radarr:x,u:sonarr:x,u:lidarr:x,u:bazarr:x /home/jellyfin /home/jellyfin/media

      ${pkgs.acl}/bin/setfacl -d -m u:radarr:rwx,u:bazarr:rwx /home/jellyfin/media/movies
      ${pkgs.acl}/bin/setfacl -m u:radarr:rwx,u:bazarr:rwx /home/jellyfin/media/movies

      ${pkgs.acl}/bin/setfacl -d -m u:sonarr:rwx,u:bazarr:rwx /home/jellyfin/media/shows
      ${pkgs.acl}/bin/setfacl -m u:sonarr:rwx,u:bazarr:rwx /home/jellyfin/media/shows
    '';
    deps = [ ];
  };

  users.users.radarr.extraGroups = [
    "media"
    "qbittorrent"
    "arr"
  ];
  users.users.sonarr.extraGroups = [
    "media"
    "qbittorrent"
    "arr"
  ];
  users.users.lidarr.extraGroups = [
    "media"
    "qbittorrent"
    "arr"
  ];
  users.users.bazarr.extraGroups = [
    "media"
    "qbittorrent"
    "arr"
  ];

  services.radarr = {
    enable = true;
    dataDir = "/var/lib/radarr";
  };

  services.sonarr = {
    enable = true;
    dataDir = "/var/lib/sonarr";
  };

  services.lidarr = {
    enable = true;
    dataDir = "/var/lib/lidarr";
  };

  services.bazarr = {
    enable = true;
  };

  services.prowlarr = {
    enable = true;
  };

  services.flaresolverr = {
    enable = true;
  };

  services.seerr = {
    enable = true;
  };

  systemd.services.radarr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];

      ReadWritePaths = [
        "/var/lib/radarr"
        "/var/log/arr"
        "/etc/arr"
        "/var/lib/qBittorrent/qBittorrent/downloads/radarr"
        "/home/jellyfin/media/movies"
      ];
      ProtectHome = lib.mkForce false;
    };
  };

  systemd.services.sonarr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];

      ReadWritePaths = [
        "/var/lib/sonarr"
        "/var/log/arr"
        "/etc/arr"
        "/var/lib/qBittorrent/qBittorrent/downloads/sonarr"
        "/home/jellyfin/media/shows"
      ];
      ProtectHome = lib.mkForce false;
    };
  };

  systemd.services.bazarr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];

      ReadWritePaths = [
        "/var/lib/bazarr"
        "/var/log/arr"
        "/etc/arr"
        "/var/lib/qBittorrent/qBittorrent/downloads/bazarr"
        "/home/jellyfin/media/movies"
        "/home/jellyfin/media/shows"
      ];
      ProtectHome = lib.mkForce false;
    };
  };

  systemd.services.lidarr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];

      ReadWritePaths = [
        "/var/lib/lidarr"
        "/var/log/arr"
        "/etc/arr"
        "/var/lib/qBittorrent/qBittorrent/downloads"
      ];
      ProtectHome = lib.mkForce false;
    };
  };

  systemd.services.prowlarr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];
    };
  };

  systemd.services.flaresolverr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];
    };
  };

  systemd.services.seerr = {
    bindsTo = [ "wireguard-wg1.service" ];
    after = [ "wireguard-wg1.service" ];

    serviceConfig = {
      Environment = [ "LIBC=glibc" ];
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];
    };
  };
}
