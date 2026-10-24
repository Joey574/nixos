{ config, pkgs, ... }:

let
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 9090 ];

  # prometheus collector for qbittorrent
  systemd.services.prometheus-qbittorrent-exporter = {
    description = "Prometheus Qbittorrent exporter";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.prometheus-qbittorrent-exporter}/bin/qbit-exp";
      Restart = "on-failure";
      EnvironmentFile = "/etc/secrets/qbit-exp.env";
    };
  };

  # Prometheus daemon
  services.prometheus = {
    enable = true;
    port = 9090;
    retentionTime = "60d";
    listenAddress = "0.0.0.0";
    globalConfig.scrape_interval = "30s";

    exporters.node.extraFlags = [ "--collector.textfile.directory=/var/lib/node-exporter-textfiles" ];

    scrapeConfigs = [
      {
        job_name = "orin";
        static_configs = [
          {
            targets = [
              "orin.netbird.cloud:9100"
              "orin.netbird.cloud:9633"
            ];
          }
        ];
      }
      {
        job_name = "server1";
        static_configs = [
          {
            targets = [
              "server1.netbird.cloud:9100"
              "server1.netbird.cloud:9633"
            ];
          }
        ];
      }
      {
        job_name = "server2";
        static_configs = [
          {
            targets = [
              "127.0.0.1:9100"
              "127.0.0.1:9633"
              "127.0.0.1:8000"
              "127.0.0.1:8096"
            ];
          }
        ];
      }
      {
        job_name = "server3";
        static_configs = [
          {
            targets = [
              "server3.netbird.cloud:9100"
              "server3.netbird.cloud:9633"
            ];
          }
          {
            targets = [ "server3.netbird.cloud:80" ];
            labels = {
              __metrics_path__ = "/-/metrics";
            };
          }
        ];
      }
      {
        job_name = "server4";
        static_configs = [
          {
            targets = [
              "server4.netbird.cloud:9100"
              "server4.netbird.cloud:9633"
            ];
          }
        ];
      }
    ];
  };
}
