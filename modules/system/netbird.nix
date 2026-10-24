{ config, lib, ... }:

let
  cfg = config.my.system;
  nb = cfg.netbird;
  unstable = import <nixos-unstable> { };
in
{
  config = lib.mkMerge [
    (lib.mkIf nb.enable {
      services.netbird.package = unstable.netbird;
      services.netbird.ui.package = unstable.netbird-ui;
    })

    (lib.mkIf (nb.enable && (!nb.interactive)) {
      services.netbird.clients.wt0 = {

        login = {
          enable = true;
          setupKeyFile = "/etc/secrets/netbird-setup-key";
        };

        port = 51821;
        ui.enable = false;
        openFirewall = true;
        openInternalFirewall = true;
      };
    })

    (lib.mkIf (nb.enable && nb.interactive) {
      services.netbird = {
        enable = true;
        ui.enable = false; # TODO : ui.enable ends in error
      };

      environment.systemPackages = [
        unstable.netbird-ui
      ];
    })
  ];
}
