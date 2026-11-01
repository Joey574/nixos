{ config, lib, pkgs, ... }:

let
  cfg = config.my.system;
in
{
  config = (lib.mkIf cfg.workspace == "i3" {
    hardware.bluetooth.enable = true;

    services.xserver = {
      enable = true;

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
        ];
      };
    };
  });
}
