{ config, pkgs, ... }:

let
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 9090 ];
  services.nginx.virtualHosts."server4.netbird.cloud".listen = [
    {
      addr = "0.0.0.0";
      port = 9090;
    }
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud35;
    hostName = "server4.netbird.cloud";

    configureRedis = true;

    database.createLocally = true;

    config = {
      adminpassFile = "/etc/secrets/nextcloud-admin-pass";
      dbtype = "pgsql";
    };

    settings = {
      maintenance_window_start = 1;
      default_phone_region = "DE";
      log_type = "systemd";
      serverid = 0;
    };

    extraAppsEnable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        contacts
        calendar
        tasks
        notes
        ;
    };
  };
}
