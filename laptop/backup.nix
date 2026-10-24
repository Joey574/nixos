{ ... }:

{
  imports = [ ../modules/kopia ];

  my.kopia = {
    enable = true;
    serverUrl = "https://server4.netbird.cloud:51515";

    passwordFile = "/etc/secrets/kopia-laptop-pw";
    certFingerprint = "a0b15e0689931e825c1127928e6c25c2f08274f5a40b72c6a300a4e9c6f6a61a";

    schedule = "*-*-* 12:00:00";
    paths = [
      "/etc/ssh"
      "/etc/secrets"
      "/var/lib/harmonia"
      "/home/joey"
    ];

    preScript = "systemctl stop harmonia.service";
    postScript = "systemctl start harmonia.service";
  };
}
