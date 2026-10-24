{ config, pkgs, ... }:

let
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 27458 ];

  # dedicated kiwix user and group
  users.users.kiwix = {
    isSystemUser = true;
    group = "kiwix";
  };
  users.groups.kiwix = { };

  systemd.tmpfiles.rules = [ "d /var/lib/kiwix 0755 kiwix kiwix -" ];

  # systemd service for kiwix server
  systemd.services.kiwix = {
    description = "kiwix zim server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.kiwix-tools}/bin/kiwix-serve --skipInvalid --monitorLibrary -p 27458 --library /var/lib/kiwix/library.xml";
      Restart = "always";
      User = "kiwix";
      Group = "kiwix";
    };
  };
}
