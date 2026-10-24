{
  config,
  lib,
  pkgs,
  ...
}:

let
  qbitCompleteScript = pkgs.writeShellScript "qbit-complete" ''
    echo "changing perms to 775"
    chmod 0775 "$1"
    if [ -d "$1" ]; then
      chmod 0775 -R "$1"/*
    fi
  '';

  publishPath = "/run/wgrot/qbit-port";
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 8080 ];

  environment.etc."qbit/qbit-complete.sh" = {
    source = qbitCompleteScript;
    mode = "0750";
    user = "qbittorrent";
    group = "qbittorrent";
  };

  # allow qbittorrent to access jellyfin movies for seeding
  system.activationScripts.qbittorrentMediaAccess = {
    text = ''
      ${pkgs.acl}/bin/setfacl -m u:qbittorrent:x /home/jellyfin
      ${pkgs.acl}/bin/setfacl -m u:qbittorrent:x /home/jellyfin/media

      ${pkgs.acl}/bin/setfacl -m u:qbittorrent:rx /home/jellyfin/media/movies
      ${pkgs.acl}/bin/setfacl -m u:qbittorrent:rx /home/jellyfin/media/shows

      ${pkgs.acl}/bin/setfacl -d -m u:qbittorrent:rx /home/jellyfin/media/movies
      ${pkgs.acl}/bin/setfacl -d -m u:qbittorrent:rx /home/jellyfin/media/shows
    '';
    deps = [ ];
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = false;
    extraArgs = [ "--confirm-legal-notice" ];
  };

  # extend qbit to be able to access other folders
  users.users.qbittorrent.extraGroups = [
    "kiwix"
    "arr"
    "media"
  ];

  systemd.services.qbittorrent = {
    bindsTo = [ "wireguard-wg0.service" ];
    after = [ "wireguard-wg0.service" ];

    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/vpn-qbit";
      ReadWritePaths = [
        "/etc/netns/vpn-qbit"
        "/home/kiwix/data"
        "/home/jellyfin/media/movies"
      ];
      BindReadOnlyPaths = [
        "/etc/netns/vpn-qbit/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-qbit/nsswitch.conf:/etc/nsswitch.conf"
      ];
      ProtectHome = lib.mkForce false;
    };
  };

  systemd.paths.qbittorrent-port-publish = {
    wantedBy = [ "multi-user.target" ];

    pathConfig = {
      PathChanged = "${publishPath}";
      Unit = "qbittorrent-port-publish.service";
    };
  };

  # systemd service to automatically fetch protonvpn port and configure qbittorrent to use it
  systemd.services.qbittorrent-port-publish = {
    description = "Push proton forwarded port to qbittorrent";
    requires = [ "qbittorrent.service" ];
    after = [ "qbittorrent.service" ];

    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "2s";

      NetworkNamespacePath = "/var/run/netns/vpn-qbit";
      ExecStart = pkgs.writeShellScript "qbittorrent-port-publish" ''
        set -eu
        source /etc/secrets/qbit-vpn.env

        PORT=$(cat "${publishPath}" 2>/dev/null || true)
        if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
            echo "No valid forwarded port"
            exit 0
        fi

        COOKIE=$(mktemp)
        trap '${pkgs.coreutils}/bin/rm -f "$COOKIE"' exit

        ${pkgs.curl}/bin/curl \
          -fsS \
          --connect-timeout 5 \
          --max-time 10 \
          -c "$COOKIE" \
          -d "username=$QBIT_USER&password=$QBIT_PASS" \
          "http://$QBIT_HOST:$QBIT_PORT/api/v2/auth/login" \
          >/dev/null

        ${pkgs.curl}/bin/curl \
          -fsS \
          --connect-timeout 5 \
          --max-time 10 \
          -b "$COOKIE" \
          -d "json={\"listen_port\":$PORT,\"upnp\":false,\"natpmp\":false}" \
          "http://$QBIT_HOST:$QBIT_PORT/api/v2/app/setPreferences" \
          >/dev/null

        echo "qbit listening port updated to $PORT"
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qBittorrent/qBittorrent/downloads 0775 qbittorrent qbittorrent -"
  ];
}
