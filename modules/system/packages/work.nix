{ config, lib, ... }:

{
  config = lib.mkIf (builtins.elem "work" config.my.system.packageSets) {
    my.system.unfreePackages = [
      "discord"
      "spotify"
    ];
  };
}
