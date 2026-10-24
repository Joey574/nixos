{ config, lib, ... }:
let
  cfg = config.my.system;
  nets = [
    "127.0.0.1"
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "100.81.0.0/16"
    "fd4e:5d3d:8c02:f114::/64"
  ];
in
{
  config = lib.mkIf cfg.network.enableSSH {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        MaxAuthTries = 3;

        AllowUsers = map (n: "${cfg.user}@${n}") nets ++ map (n: "nixbuild@${n}") nets;
      };
    };

    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
    };
  };
}
