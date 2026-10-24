{ config, lib, ... }:

{
  config = lib.mkIf (builtins.elem "work" config.my.system.packageSets) {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
        "spotify"
      ];
  };
}
