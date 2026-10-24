{ config, ... }:

let
  domain = "vault.topoview.org";
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 443 ];

  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    backupDir = "/var/local/vaultwarden";

    environmentFile = "/etc/secrets/vaultwarden.env";
    config = {
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "joeysoroka@outlook.com";
    certs.${domain} = {
      dnsProvider = "cloudflare";
      environmentFile = "/etc/secrets/cloudflare-acme.env";
      group = "nginx";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts.${domain} = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
        proxyWebsockets = true;
      };
    };
  };
}
