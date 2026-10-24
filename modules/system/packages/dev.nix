{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (builtins.elem "dev" config.my.system.packageSets) {
    programs.git = {
      enable = true;
      config = {
        user.name = "Joey574";
        user.email = "joeysoroka@outlook.com";
        credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        credential."https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
    };
  };
}
