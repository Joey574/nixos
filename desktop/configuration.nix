{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
    ./graphics.nix
    ./mounts.nix
    ./system.nix
    ./upgrade.nix
  ];

  my.system = {
    network = {
      hostname = "desktop";
      enableSSH = true;
      privateInterface = "nb-wt0";
    };

    cache = {
      enable = true;
      serve = true;
    };

    kernel = "linux_zen";
    tuning = {
      enable = true;
      arch = "znver4";
      tune = "znver4";
    };

    netbird = {
      enable = true;
      interactive = true;
    };

    user = "joey";
    workspace = "plasma";

    packageSets = [
      "dev"
      "kde"
      "util"
      "work"
      "games"
    ];
  };

  networking.hostId = "cabecee6";

  system.stateVersion = "26.05";
}
