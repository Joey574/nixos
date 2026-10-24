{
  lib,
  pkgs,
  ...
}:

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
    ./ssh.nix
    ./tuning.nix
    ./users.nix
  ];

  config = lib.mkMerge [
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.systemd-boot.configurationLimit = 5;

      boot.kernelModules = [ "tcp_bbr" ];
      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };

      time.timeZone = "America/Los_Angeles";

      nix.settings = {
        keep-outputs = true;
        keep-derivations = true;
        auto-optimise-store = true;
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      programs.bash.interactiveShellInit = ''
        ${pkgs.fastfetch}/bin/fastfetch
      '';

      services.journald = {
        extraConfig = ''
          SystemMaxUse=500M
          Storage=persistent
        '';
      };
    }
  ];
}
