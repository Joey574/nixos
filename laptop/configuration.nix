{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
  ];

  my.system = {
    network = {
      hostname = "laptop";
      enableSSH = true;
      privateInterface = "wt0";

      randomizeMac = true;
      hideHostname = true;
    };

    cache = {
      enable = true;
      serve = true;
    };

    kernel = "linux_zen";
    tuning = {
      enable = true;
      arch = "znver3";
      tune = "znver3";
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
    ];
  };

  system.stateVersion = "26.05";
}
