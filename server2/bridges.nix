{ lib, pkgs, ... }:

let
  netnsUnit = {
    vpn-qbit = "wireguard-wg0.service";
    vpn-arr = "wireguard-wg1.service";
  };

  pullLabel = namespace: if namespace == null then "host" else namespace;

  mkBridge =
    {
      name,
      upstream,
      sourcePort,
      sourceNamespace ? null,
      pulls,
    }:
    let
      socketDir = "${name}-bridge";
      socketPath = "/run/${socketDir}/${name}.sock";
      pushUnit = "${name}-push";
      identity = socketDir;

      netnsDeps = ns: lib.optional (ns != null) netnsUnit.${ns};

      push = {
        systemd.services.${pushUnit} = {
          description = "expose ${name} (${upstream}) as a unix socket";
          after = [ upstream ] ++ netnsDeps sourceNamespace;
          bindsTo = [ upstream ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            DynamicUser = true;
            User = identity;
            RuntimeDirectory = socketDir;
            RuntimeDirectoryMode = "0700";
            Restart = "always";
            ExecStart = "${pkgs.socat}/bin/socat UNIX-LISTEN:${socketPath},fork,unlink-early,mode=660 TCP:127.0.0.1:${toString sourcePort}";
          }
          // lib.optionalAttrs (sourceNamespace != null) {
            NetworkNamespacePath = "/var/run/netns/${sourceNamespace}";
          };
        };
      };

      mkPull =
        {
          namespace ? null,
          port,
          bindAddr ? "127.0.0.1",
        }:
        {
          systemd.services."${name}-pull-${pullLabel namespace}" = {
            description =
              "export the ${name} socket as TCP ${toString port}"
              + lib.optionalString (namespace != null) " in ${namespace}";
            after = [ "${pushUnit}.service" ] ++ netnsDeps namespace;
            bindsTo = [ "${pushUnit}.service" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              DynamicUser = true;
              User = identity;
              Restart = "always";
              ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},bind=${bindAddr},fork,reuseaddr UNIX-CONNECT:${socketPath}";
            }
            // lib.optionalAttrs (namespace != null) {
              NetworkNamespacePath = "/var/run/netns/${namespace}";
            };
          };
        };
    in
    lib.mkMerge ([ push ] ++ map mkPull pulls);

  bridges = [
    {
      name = "radarr-webui";
      upstream = "radarr.service";
      sourcePort = 7878;
      sourceNamespace = "vpn-arr";
      pulls = [
        {
          port = 7878;
          bindAddr = "0.0.0.0";
        }
      ];
    }

    {
      name = "sonarr-webui";
      upstream = "sonarr.service";
      sourcePort = 8989;
      sourceNamespace = "vpn-arr";
      pulls = [
        {
          port = 8989;
          bindAddr = "0.0.0.0";
        }
      ];
    }

    {
      name = "lidarr-webui";
      upstream = "lidarr.service";
      sourcePort = 8686;
      sourceNamespace = "vpn-arr";
      pulls = [
        {
          port = 8686;
          bindAddr = "0.0.0.0";
        }
      ];
    }

    {
      name = "bazarr-webui";
      upstream = "bazarr.service";
      sourcePort = 6767;
      sourceNamespace = "vpn-arr";
      pulls = [
        {
          port = 6767;
          bindAddr = "0.0.0.0";
        }
      ];
    }

    {
      name = "prowlarr-webui";
      upstream = "prowlarr.service";
      sourcePort = 9696;
      sourceNamespace = "vpn-arr";
      pulls = [
        {
          port = 9696;
          bindAddr = "0.0.0.0";
        }
      ];
    }

    {
      name = "seerr-webui";
      upstream = "seerr.service";
      sourcePort = 5055;
      sourceNamespace = "vpn-arr";
      pulls = [
        {
          port = 5055;
          bindAddr = "0.0.0.0";
        }
      ];
    }

    {
      name = "qbit-webui";
      upstream = "qbittorrent.service";
      sourcePort = 8080;
      sourceNamespace = "vpn-qbit";
      pulls = [
        {
          port = 8080;
          bindAddr = "0.0.0.0";
        }
        {
          namespace = "vpn-arr";
          port = 8080;
        }
      ];
    }

    {
      name = "jellyfin";
      upstream = "jellyfin.service";
      sourcePort = 8096;
      sourceNamespace = null;
      pulls = [
        {
          namespace = "vpn-arr";
          port = 8096;
        }
      ];
    }
  ];
in
lib.mkMerge (map mkBridge bridges)
