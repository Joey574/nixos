{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.system;
in
{
  config = lib.mkIf (builtins.elem "games" config.my.system.packageSets) {
    my.system.unfreePackages = [
      "steam"
      "steam-unwrapped"
    ];

    # pulled in just for Sober support, do not use elsewise
    services.flatpak.enable = true;

    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    users.users.${cfg.user}.extraGroups = [ "adbusers" ];
    services.wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = true;
    };
  };
}
