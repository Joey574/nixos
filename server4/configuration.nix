{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
    ./kopia-server.nix
    ./immich.nix
    ./nextcloud.nix
    ./vaultwarden.nix
    ../shared/legacy-graphics.nix
  ];

  my.system = {
    user = "admin";

    network = {
      hostname = "server4";
      enableSSH = true;
      privateInterface = "nb-wt0";
    };

    tuning = {
      enable = true;
      arch = "znver1";
      tune = "znver1";
    };

    cache.enable = true;
    netbird.enable = true;
    exporters.enable = true;

    packageSets = [ "util" ];
  };

  system.stateVersion = "26.05";
}
