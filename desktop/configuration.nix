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
      enable = false;
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
    plasma.wp-engine.enable = true;

    packageSets = [
      "dev"
      "kde"
      "util"
      "work"
      "games"
    ];
  };

  system.stateVersion = "26.05";
}
