{ config, pkgs, ... }:

let
  webDirStore = "/nix/store/xwkyaal64lcdw4zyc39zx0qjsvzpkk3i-jellyfin-web-10.11.11/share/jellyfin-web";
  dataDir = "/var/lib/jellyfin";
  configDir = "/var/lib/jellyfin/config";
  cacheDir = "/var/cache/jellyfin";
  logDir = "/var/lib/jellyfin/log";
  webDir = "/home/jellyfin/web";

  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 8096 ];

  # Jellyfin user config
  users.groups.media = { };
  users.users.jellyfin = {
    home = "/home/jellyfin";
    extraGroups = [
      "render"
      "video"
      "media"
    ];
  };

  # Enforce jellyfin permissions
  systemd.tmpfiles.rules = [
    "d /home/jellyfin 0750 jellyfin jellyfin -"

    "d ${configDir} 0700 jellyfin jellyfin -"
    "d ${dataDir} 0700 jellyfin jellyfin -"
    "d ${cacheDir} 0700 jellyfin jellyfin -"
    "d ${logDir} 0700 jellyfin jellyfin -"
    "d ${webDir} 0700 jellyfin jellyfin -"

    "z /home/jellyfin/media 2750 jellyfin jellyfin -"
    "d /home/jellyfin/media/movies 2770 jellyfin media -"
    "d /home/jellyfin/media/bridge 2770 jellyfin media -"
    "d /home/jellyfin/media/shows 2770 jellyfin media -"
  ];

  services.jellyfin = {
    enable = true;

    configDir = configDir;
    dataDir = dataDir;
    cacheDir = cacheDir;
    logDir = logDir;
  };

  # sync web data
  systemd.services.jellyfin-web-sync = {
    description = "sync jellyfin web dir";
    before = [ "jellyfin.service" ];
    requiredBy = [ "jellyfin.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "jellyfin";
      Group = "jellyfin";
      ExecStart = "${pkgs.rsync}/bin/rsync -a --delete ${webDirStore}/ ${webDir}/";
    };
  };

  # enable jellyfin metrics and bind web dir path
  systemd.services.jellyfin = {
    preStart =
      let
        systemXml = "/home/jellyfin/config/system.xml";
      in
      ''
        if [ -f "${systemXml}" ]; then
          ${pkgs.gnused}/bin/sed -i \
            's#<EnableMetrics>false</EnableMetrics>#<EnableMetrics>true</EnableMetrics>#' \
            "${systemXml}"
        fi
      '';

    serviceConfig.BindPaths = [
      "${webDir}:${webDirStore}"
    ];
  };
}
