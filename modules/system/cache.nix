{ config, lib, ... }:

let
  cfg = config.my.system;
  net = cfg.network;
  cache = cfg.cache;
in
{
  config = lib.mkMerge [
    (lib.mkIf cache.serve {
      networking.firewall.interfaces.${net.privateInterface}.allowedTCPPorts = [ 5000 ];

      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [ "/var/lib/harmonia/key" ];
        settings = {
          bind = "0.0.0.0:5000";
          workers = 4;
          priority = 30;
          enable_compression = true;
        };
      };

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    })

    (lib.mkIf (!cache.serve) {
      nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    })

    (lib.mkIf cache.enable {
      nix.settings = {
        substituters = [
          "http://desktop.netbird.cloud:5000"
          "http://laptop.netbird.cloud:5000"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "desktop-cache-1:9EtjPikUe7DJQj8B7yIUIdEkUTm7oaC9iSlzwqg5R5U="
          "laptop-cache-1:Pyzsn9pxRd7/2Uiywqz4dm09J5b6/ji3QV68SV44Xf0="
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
    })
  ];
}
