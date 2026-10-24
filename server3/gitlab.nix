{ config, ... }:

let
  domain = "server3.netbird.cloud";
  secretsDir = "/var/lib/gitlab-secrets";
  backupDir = "/var/backup/gitlab";
  secret = name: "${secretsDir}/${name}";

  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 80 ];

  services.openssh.settings.AllowUsers = [
    "gitlab@192.168.0.0/16"
    "gitlab@100.81.0.0/16"
    "gitlab@fd4e:5d3d:8c02:f114::/64"
  ];

  services.gitlab = {
    enable = true;
    host = domain;
    https = false;
    port = 80;

    initialRootEmail = "joeysoroka@outlook.com";
    initialRootPasswordFile = secret "root-password";

    secrets = {
      secretFile = secret "secret";
      dbFile = secret "db";
      otpFile = secret "otp";
      jwsFile = secret "jws";
      activeRecordPrimaryKeyFile = secret "ar-primary";
      activeRecordDeterministicKeyFile = secret "ar-deterministic";
      activeRecordSaltFile = secret "ar-salt";
    };

    puma = {
      workers = 0;
      threadsMin = 1;
      threadsMax = 4;
    };
    sidekiq.concurrency = 5;

    backup = {
      startAt = "03:00";
      path = backupDir;
      keepTime = 48;
      skip = [
        "artifacts"
        "registry"
      ];
    };

    extraConfig = {

      gitlab.default_projects_features = {
        issues = true;
        merge_requests = true;
        wiki = false;
        snippets = false;
        builds = false;
      };

      monitoring.ip_whitelist = [
        "127.0.0.0/8"
        "::1/128"
        "100.81.0.0/16"
        "fd4e:5d3d:8c02:f114::/64"
      ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    clientMaxBodySize = "0";

    virtualHosts.${domain} = {
      locations."/" = {
        proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
        proxyWebsockets = true;
      };

      locations."/-/" = {
        proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };
}
