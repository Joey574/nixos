{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.kopiaServer;
  state = "/var/lib/kopia-server";

  env = {
    KOPIA_CONFIG_PATH = "${state}/repository.config";
    KOPIA_CACHE_DIRECTORY = "/var/cache/kopia-server";
    KOPIA_CHECK_FOR_UPDATES = "false";
  };

  policyFile = pkgs.writeText "kopia-policies.json" (
    builtins.toJSON (
      lib.listToAttrs (
        map (
          p:
          lib.nameValuePair p.source (
            lib.filterAttrsRecursive (_: v: v != null) {
              compression.compressorName = p.compression;
              files.ignore = p.ignore;
              retention = {
                keepLatest = p.keepLatest;
                keepHourly = p.keepHourly;
                keepDaily = p.keepDaily;
                keepWeekly = p.keepWeekly;
                keepMonthly = p.keepMonthly;
                keepAnnual = p.keepAnnual;
              };
            }
          )
        ) cfg.policies
      )
    )
  );

  applyPolicies = pkgs.writeShellScript "kopia-apply-policies" ''
    set -eu
    export KOPIA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/repo-pw")"
    exec ${lib.getExe pkgs.kopia} policy import --from-file=${policyFile} ${lib.optionalString cfg.declarative "--delete-other-policies"}
  '';

  g = cfg.global;
  flag = name: v: lib.optional (v != null) "--${name}=${toString v}";
  globalArgs = lib.concatLists [
    (flag "compression" g.compression)
    (flag "keep-latest" g.keepLatest)
    (flag "keep-hourly" g.keepHourly)
    (flag "keep-daily" g.keepDaily)
    (flag "keep-weekly" g.keepWeekly)
    (flag "keep-monthly" g.keepMonthly)
    (flag "keep-annual" g.keepAnnual)
  ];

  applyGlobal = pkgs.writeShellScript "kopia-apply-global" ''
    set -eu
    export KOPIA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/repo-pw")"

    kopia=${lib.getExe pkgs.kopia}
    ${lib.optionalString (
      globalArgs != [ ]
    ) "$kopia policy set --global ${lib.escapeShellArgs globalArgs}"}
    ${lib.optionalString (g.ignore != null) ''
      $kopia policy set --global --clear-ignore
      ${lib.optionalString (g.ignore != [ ]) ''
        $kopia policy set --global ${
          lib.concatMapStringsSep " " (i: "--add-ignore ${lib.escapeShellArg i}") g.ignore
        }
      ''}
    ''}
  '';

  credName = name: "user-" + lib.replaceStrings [ "@" ] [ "_at_" ] name;

  applyUsers = pkgs.writeShellScript "kopia-apply-users" ''
    set -eu
    export KOPIA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/repo-pw")"

    kopia=${lib.getExe pkgs.kopia}
    ${lib.concatStrings (
      lib.mapAttrsToList (name: _: ''
        pw="$(cat "$CREDENTIALS_DIRECTORY/${credName name}")"
        $kopia server user set ${lib.escapeShellArg name} --user-password="$pw" \
          || $kopia server user add ${lib.escapeShellArg name} --user-password="$pw"
      '') cfg.users
    )}
  '';
in
{
  imports = [ ./server-options.nix ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = lib.all (n: builtins.match "[^@]+@[^@]+" n != null) (lib.attrNames cfg.users);
          message = "my.kopiaServer.users names must be of the form user@host";
        }
      ];

      environment.systemPackages = [ pkgs.kopia ];
      networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ cfg.port ];

      systemd.services.kopia-server = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        unitConfig = {
          RequiresMountsFor = [ cfg.repoPath ];
          ConditionPathExists = [
            "${state}/repository.config"
            "${state}/server.crt"
          ];
        };

        path = [ pkgs.kopia ];
        environment = env;
        serviceConfig = {
          ExecStartPre =
            lib.optional (cfg.users != { }) "${applyUsers}"
            ++ lib.optional (cfg.policies != [ ]) "${applyPolicies}"
            ++ lib.optional (globalArgs != [ ]) "${applyGlobal}";

          LoadCredential = [
            "repo-pw:/etc/secrets/kopia-repo-pw"
            "ctl-pw:/etc/secrets/kopia-server-control-pw"
          ]
          ++ lib.mapAttrsToList (n: u: "${credName n}:${u.passwordFile}") cfg.users;

          StateDirectory = "kopia-server";
          CacheDirectory = "kopia-server";

          Restart = "on-failure";
          RestartSec = "30s";
        };
        script = ''
          export KOPIA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/repo-pw")"
          export KOPIA_SERVER_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/ctl-pw")"

          exec kopia server start \
            --address=${cfg.address}:${toString cfg.port} \
            --tls-cert-file=${state}/server.crt \
            --tls-key-file=${state}/server.key \
            --server-username=admin
        '';
      };
    })

    (lib.mkIf (cfg.enable && cfg.offsite.enable) {
      systemd.services.kopia-offsite-sync = {
        unitConfig.RequiresMountsFor = [ cfg.repoPath ];
        path = [ pkgs.kopia ];
        environment = env;
        serviceConfig = {
          Type = "oneshot";
          StateDirectory = "kopia-server";
          CacheDirectory = "kopia-server";
          TimeoutStartSec = "infinity";
          Nice = 10;
          LoadCredential = [
            "repo-pw:/etc/secrets/kopia-repo-pw"
            "id:/etc/secrets/offsite-key-id"
            "key:/etc/secrets/offsite-key"
          ];
        };
        script = ''
          export KOPIA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/repo-pw")"
          # TODO swap once provider is chosen, likely backblaze b2
          #kopia repository sync-to b2 \
          #  --bucket ${cfg.offsite.bucket} \
          #  --key-id "$(cat "$CREDENTIALS_DIRECTORY/id")" \
          #  --key "$(cat "$CREDENTIALS_DIRECTORY/key")" \
          #  --delete --parallel 8
        '';
      };
      systemd.timers.kopia-offsite-sync = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.offsite.schedule;
          Persistent = true;
        };
      };
    })
  ];
}
