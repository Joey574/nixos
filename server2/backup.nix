{ ... }:

let
  units = [
    "jellyfin.service"
    "radarr.service"
    "sonarr.service"
    "lidarr.service"
    "bazarr.service"
    "seerr.service"
    "navidrome.service"
  ];
in
{
  imports = [ ../modules/kopia ];

  my.kopia = {
    enable = true;
    serverUrl = "https://server4.netbird.cloud:51515";

    passwordFile = "/etc/secrets/kopia-server2-pw";
    certFingerprint = "a0b15e0689931e825c1127928e6c25c2f08274f5a40b72c6a300a4e9c6f6a61a";

    schedule = "*-*-* 03:30:00";
    paths = [
      "/etc/ssh"
      "/etc/secrets"
      "/var/lib/jellyfin"
      "/var/lib/radarr"
      "/var/lib/sonarr"
      "/var/lib/lidarr"
      "/var/lib/bazarr"
      "/var/lib/private/prowlarr"
      "/var/lib/private/seerr"
      "/var/lib/navidrome"
      "/var/lib/kiwix"
      "/var/lib/qBittorrent"
      "/var/lib/prometheus2"
    ];

    preScript = "systemctl stop ${toString units}";
    postScript = "systemctl start ${toString units}";
  };
}
