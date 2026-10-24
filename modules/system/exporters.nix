{ config, lib, ... }:

let
  cfg = config.my.system;
  net = cfg.network;
  exp = cfg.exporters;
in
{
  config = lib.mkIf exp.enable {
    networking.firewall.interfaces.${net.privateInterface}.allowedTCPPorts = [
      9100
      9633
    ];

    services.prometheus.exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [ "systemd" ];
      };

      smartctl = {
        enable = true;
        port = 9633;
      };
    };
  };
}
