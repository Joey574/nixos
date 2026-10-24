{ config, lib, pkgs, ... }:

{
  networking.hostName = "bootstrap";

  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.networkmanager.enable = true;

  nix.settings.trusted-users = [
    "root"
    "admin"
  ];

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEXVu1IO0zha66nhXvHHDcwR9r7xx3nbSIAN4elIyAj joeysoroka@outlook.com"
    ];
  };

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [
        "admin@192.168.0.0/16"
        "admin@100.81.*"
        "admin@fd4e:5d3d:8c02:f114:*"
      ];
    };
  };

  services.resolved.enable = true;

  services.netbird.clients.wt0 = {
    login = {
      enable = true;
      setupKeyFile = "/etc/secrets/netbird-setup-key";
    };

    port = 51821;
    ui.enable = false;
    openFirewall = true;
    openInternalFirewall = true;
  };

  system.stateVersion = "26.05";
}
