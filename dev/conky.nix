{ pkgs, ... }:

# TODO
# this is just completely broken rn :(

let
  newsfeed = pkgs.buildGoModule {
    pname = "newsfeed";
    version = "0-unstable";

    src = pkgs.fetchFromGitHub {
      owner = "Joey574";
      repo = "newsfeed";
      rev = "f76770324c6f34876297a44c70af0dc9804402a9";

      hash = "sha256-VK5rv6911Ev8YAhXhGPva1PMjt39mcPOd4al91VTRVw=";
    };

    vendorHash = "sha256-aNUDpXH16angaPNPm6GsHqiDr1AYZb7q1dgyg4p8JjM=";
  };
in
{
  environment.systemPackages = [
    pkgs.conky
    newsfeed
  ];

  systemd.user.services =
    let
      mkConky = name: colors: {
        description = "conky ${name}";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        path = [
          newsfeed
          pkgs.util-linux
          pkgs.coreutils
          pkgs.gnused
        ];
        environment = colors;
        serviceConfig = {
          ExecStart = "${pkgs.conky}/bin/conky -c %h/.config/conky/${name}.conf";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    in
    {
      conky-l = mkConky "conky-l" {
        COLOR1 = "#317ead";
        COLOR2 = "#ffffff";
      };
      conky-r = mkConky "conky-r" {
        COLOR1 = "#317ead";
        COLOR2 = "#ffffff";
      };
    };
}
