{
  config,
  lib,
  ...
}:

let
  cfg = config.my.system;
  pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEXVu1IO0zha66nhXvHHDcwR9r7xx3nbSIAN4elIyAj joeysoroka@outlook.com";
  buildKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBLn+uXAKb1b25ef25+zvvD1cUOJg/v4BDYzBif5eP5j root@desktop";
in
{
  config = lib.mkMerge [
    {
      nix.settings.trusted-users = [
        "nixbuild"
        "${cfg.user}"
      ];
      users.groups.nixbuild = { };

      users.users.nixbuild = {
        isSystemUser = true;
        group = "nixbuild";
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [ "${buildKey}" ];
      };

      users.users.${cfg.user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ "${pubKey}" ];
      };
    }
  ];
}
