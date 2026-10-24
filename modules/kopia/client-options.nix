{ lib, ... }:

{
  options.my.kopia = {
    enable = lib.mkEnableOption "kopia client";

    serverUrl = lib.mkOption {
      type = lib.types.str;
    };

    certFingerprint = lib.mkOption {
      type = lib.types.str;
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      description = "path to password file";
    };

    declarative = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to delete all policies not defined by this module.
        Passes `--delete-other-policies` to `kopia policy import`.
      '';
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    ignore = lib.mkOption {

    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
    };

    preScript = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    postScript = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };
}
