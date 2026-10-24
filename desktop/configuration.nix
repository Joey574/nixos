{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
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
    ];
  };

  networking.hostId = "cabecee6";

  # pulled in just for Sober support, do not use elsewise
  services.flatpak.enable = true;
  users.users.joey.extraGroups = [ "adbusers" ];

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  services.wivrn = {
    enable = true;
    openFirewall = true;
    autoStart = true;
  };

  environment.systemPackages = with pkgs; [
    (prismlauncher.override { })
  ];

  system.stateVersion = "26.05";
}
