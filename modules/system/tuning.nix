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
  # TODO
  # not actually sure if this sets the kernel package lmao, should probably make it do that too

  config = (
    lib.mkIf tuning.enable {
      nixpkgs.hostPlatform = {
        system = "${cfg.system}";
        gcc.arch = "${tuning.arch}";
        gcc.tune = "${tuning.tune}";
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
    }
  );
}
