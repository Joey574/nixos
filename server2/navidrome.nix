{ config, ... }:

let
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 4533 ];

  services.navidrome = {
    enable = true;
    openFirewall = true;

    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/mnt/storage/navidrome-data";
    };
  };
}
