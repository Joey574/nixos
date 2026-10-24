{ lib, ... }:

{
  options.my.kopiaServer = {
    enable = lib.mkEnableOption "kopia server";

    repoPath = lib.mkOption {
      type = lib.types.str;
      example = "/mnt/kopia";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 51515;
    };

    declarative = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to delete all policies not defined by this module.
        Passes `--delete-other-policies` to `kopia policy import`.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.passwordFile = lib.mkOption {
            type = lib.types.pathWith {
              absolute = true;
              inStore = false;
            };
            description = "file containing user password";
          };
        }
      );
      default = { };
      example = {
        "admin@example".passwordHashFile = "/etc/kopia-user-admin-example";
      };
    };

    global = {
      compression = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      keepLatest = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      keepHourly = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      keepDaily = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      keepWeekly = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      keepMonthly = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      keepAnnual = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
      };

      ignore = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
      };
    };

    policies = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            source = lib.mkOption {
              type = lib.types.str;
              description = "source path for the policy.";
            };

            ignore = lib.mkOption {
              type = lib.types.nullOr (lib.types.listOf lib.types.str);
              description = "files or patterns to ignore.";
              default = null;
            };

            compression = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = "compression type to use";
              default = null;
            };

            keepLatest = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "latest backups to keep";
              default = null;
            };

            keepHourly = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "hourly backups to keep";
              default = null;
            };

            keepDaily = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "daily backups to keep";
              default = null;
            };

            keepWeekly = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "weekly backups to keep";
              default = null;
            };

            keepMonthly = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "monthly backups to keep";
              default = null;
            };

            keepAnnual = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              description = "annual backups to keep";
              default = null;
            };
          };
        }
      );
      default = [ ];
    };

    offsite = {
      enable = lib.mkEnableOption "off-site repo replication";
      bucket = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      schedule = lib.mkOption {
        type = lib.types.str;
        default = "*-*-* 05:00:00";
      };
    };
  };
}
