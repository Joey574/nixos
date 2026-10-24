{ config, ... }:

let
  iface = config.my.system.net.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 3000 ];

  services.grafana = {
    enable = true;

    settings = {
      analytics.reporting_enabled = false;

      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;

        enforce_domain = true;
        domain = "server1.netbird.cloud";
        root_url = "http://server1.netbird.cloud:3000";

        enable_gzip = true;
      };
    };

    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://100.81.253.72:9090";
          isDefault = true;
          editable = false;
        }
      ];
    };
  };
}
