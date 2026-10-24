{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
    ./webui.nix
    ./gitlab.nix
  ];

  my.system = {
    user = "admin";

    network = {
      hostname = "server3";
      enableSSH = true;
      privateInterface = "nb-wt0";
    };

    tuning = {
      enable = true;
      arch = "haswell";
      tune = "haswell";
    };

    cache.enable = true;
    netbird.enable = true;
    exporters.enable = true;

    packageSets = [ "util" ];
  };

  system.stateVersion = "26.05";
}
