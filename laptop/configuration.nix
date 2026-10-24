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
      enable = false;
      serve = true;
    };

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

    packageSets = [
      "dev"
      "kde"
      "util"
      "work"
    ];
  };

  system.stateVersion = "26.05";
}
