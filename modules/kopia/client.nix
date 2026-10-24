{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.kopia;
  state = "/var/lib/kopia";

  kopiaLocal = pkgs.writeShellScriptBin "kopia-local" ''
    export KOPIA_CONFIG_PATH=${state}/repository.config
    export KOPIA_CHECK_FOR_UPDATES=false
    exec ${pkgs.kopia}/bin/kopia "$@"
  '';
in
{
  imports = [ ./client-options.nix ];

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kopia
      kopiaLocal
    ];

    systemd.services.kopia-backup = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.kopia ];
      environment = {
        KOPIA_CONFIG_PATH = "${state}/repository.config";
        KOPIA_CACHE_DIRECTORY = "/var/cache/kopia";
        KOPIA_CHECK_FOR_UPDATES = "false";
      };

      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "kopia";
        CacheDirectory = "kopia";

        Nice = 10;
        IOSchedulingClass = "idle";

        LoadCredential = "pw:${cfg.passwordFile}";

        ExecCondition = "${pkgs.curl}/bin/curl -sk --max-time 5 -o /dev/null ${cfg.serverUrl}";
        ExecStopPost = lib.mkIf (cfg.postScript != "") (pkgs.writeShellScript "kopia-post" cfg.postScript);
      };

      script = ''
        export KOPIA_PASSWORD="$(cat "$CREDENTIALS_DIRECTORY/pw")"
        ${cfg.preScript}
        kopia repository status >/dev/null 2>&1 || \
          kopia repository connect server \
            --url ${cfg.serverUrl} \
            --server-cert-fingerprint ${cfg.certFingerprint}
        kopia snapshot create ${lib.escapeShellArgs cfg.paths}
      '';
    };

    systemd.timers.kopia-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        RandomizedDelaySec = "20m";
      };
    };
  };
}
