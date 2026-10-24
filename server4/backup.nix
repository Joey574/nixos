{ ... }:

{
  imports = [ ../modules/kopia ];

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
    location = "/var/local/postgresql";

    databases = [
      "immich"
      "nextcloud"
    ];
  };

  my.kopia = {
    enable = true;
    serverUrl = "https://localhost:51515";

    passwordFile = "/etc/secrets/kopia-server4-pw";
    certFingerprint = "a0b15e0689931e825c1127928e6c25c2f08274f5a40b72c6a300a4e9c6f6a61a";

    schedule = "*-*-* 02:00:00";
    paths = [
      "/etc/ssh"
      "/etc/secrets"
      "/var/lib/acme"
      "/var/lib/immich"
      "/var/lib/redis-immich"
      "/var/lib/nextcloud"
      "/var/lib/redis-nextcloud"
      "/var/lib/kopia-server"
      "/var/local/vaultwarden"
      "/var/local/postgresql"
    ];
  };
}
