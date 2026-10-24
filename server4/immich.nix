{ config, ... }:

let
  iface = config.my.system.network.privateInterface;
  port = 2283;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ port ];

  nixpkgs.config = {
    permittedInsecurePackages = [
      "immich-2.7.5"
    ];
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
  ];

  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = port;

    mediaLocation = "/var/lib/immich";

    accelerationDevices = null;
  };
}
