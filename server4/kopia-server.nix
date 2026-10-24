{ config, ... }:

let
  iface = config.my.system.network.privateInterface;
in
{
  imports = [ ../modules/kopia ];
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 51515 ];

  my.kopiaServer = {
    enable = true;
    declarative = true;
    address = "0.0.0.0";

    global.compression = "zstd-better-compression";

    users = {
      "root@orin".passwordFile = "/etc/secrets/kopia-orin-pw";
      "root@laptop".passwordFile = "/etc/secrets/kopia-laptop-pw";
      "root@server1".passwordFile = "/etc/secrets/kopia-server1-pw";
      "root@server2".passwordFile = "/etc/secrets/kopia-server2-pw";
      "root@server3".passwordFile = "/etc/secrets/kopia-server3-pw";
      "root@server4".passwordFile = "/etc/secrets/kopia-server4-pw";
      "root@desktop".passwordFile = "/etc/secrets/kopia-desktop-pw";
    };

    policies = [
      {
        source = "root@server4:/var/lib/immich";
        compression = "none";
        ignore = [
          "thumbs/"
          "encoded-video/"
        ];
      }
      {
        source = "root@server4:/var/lib/nextcloud";
        ignore = [ "**/appdata_*/preview/" ];
      }
      {
        source = "root@server2:/var/lib/qBittorrent";
        ignore = [ "qBittorrent/downloads/" ];
      }
      {
        source = "root@desktop:/home/joey";
        ignore = [
          "repos/"
          "go/pkg/"
          ".cache/"
          ".cargo/"
          "Nextcloud/"
          ".factorio/"
          ".local/state/"
          ".local/share/Steam/"
          ".local/share/Trash/"
          ".local/share/MLEngine/"

          ".bash_history*"
          ".python_history*"
        ];
      }
      {
        source = "root@laptop:/home/joey";
        ignore = [
          "repos/"
          "go/pkg/"
          ".cache/"
          ".cargo/"
          "Nextcloud/"
          ".local/state/"
          ".local/share/Trash/"
          ".local/share/MLEngine/"

          ".bash_history*"
          ".python_history*"
        ];
      }
    ];

    repoPath = "/var/backup/kopia-server";
    offsite = {
      enable = false;
      bucket = "TODO";
    };
  };
}
