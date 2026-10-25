{
  config,
  lib,
  pkgs,
  ...
}:
let
  sets = import ./sets.nix;
  cfg = config.my.system;
in
{
  imports = [
    ./dev.nix
    ./work.nix
    ./games.nix
  ];

  environment.systemPackages = lib.concatMap (name: sets.${name} pkgs) (lib.unique cfg.packageSets);
}
