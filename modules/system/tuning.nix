{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.system;
  tuning = cfg.tuning;
in
{
  config = lib.mkMerge [
    {
      nixpkgs.hostPlatform.system = cfg.system;
    }

    (lib.mkIf tuning.enable {
      nixpkgs.hostPlatform.gcc = {
        arch = tuning.arch;
        tune = tuning.tune;
      };

      boot.kernelPackages = pkgs.linuxPackagesFor (
        pkgs.${cfg.kernel}.override {
          extraMakeFlags = [
            "KCFLAGS=-march=${tuning.arch}"
            "CFLAGS_KERNEL=-mtune=${tuning.arch}"
            "CFLAGS_MODULE=-mtune=${tuning.tune}"
          ];
        }
      );
    })
  ];
}
