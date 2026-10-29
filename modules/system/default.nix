{
  config,
  lib,
  ...
}:

let
  cfg = config.my.system;
in
{
  imports = [
    ./packages
    ./workspaces
    ./cache.nix
    ./exporters.nix
    ./netbird.nix
    ./network.nix
    ./options.nix
    ./patches.nix
    ./shell.nix
    ./ssh.nix
    ./tuning.nix
    ./users.nix
  ];

  config = lib.mkMerge [
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 5;

      time.timeZone = "America/Los_Angeles";

      nix.settings = {
        keep-outputs = true;
        keep-derivations = true;
        auto-optimise-store = true;
      };

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.unfreePackages;

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      services.journald = {
        extraConfig = ''
          SystemMaxUse=500M
          Storage=persistent
        '';
      };
    }
  ];
}
