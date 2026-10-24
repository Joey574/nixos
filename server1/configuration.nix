{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./grafana.nix
    ./topoview.nix
    ./cloudflare.nix
  ];

  my.system = {
    user = "admin";

    network = {
      hostname = "server1";
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

  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  system.stateVersion = "26.05";
}
