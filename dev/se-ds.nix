{ ... }:

# TODO
# make this a module and submit it? could be kinda nice right?

{
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers = {
    protonvpn = {
      image = "qmcgaw/gluetun:latest";
      autoStart = true;

      environment = {
        VPN_SERVICE_PROVIDER = "custom";
        VPN_TYPE = "wireguard";
        VPN_PORT_FORWARDING = "on";
        VPN_PORT_FORWARDING_PROVIDER = "protonvpn";
      };

      environmentFiles = [ "/etc/secrets/protonvpn-se.env" ];

      volumes = [
        "/home/joey/repos/seserver/gluetun:/gluetun"
        "/home/joey/repos/seserver/gluetun_tmp:/tmp/gluetun"
      ];

      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
    };

    se-ds = {
      image = "devidian/spaceengineers:latest";
      dependsOn = [ "protonvpn" ];
      autoStart = true;

      environment = {
        INSTANCE_NAME = "se-ds";
      };

      extraOptions = [
        "--memory=32g"
        "--memory-swap=32g"
        "--network=container:protonvpn"
      ];

      volumes = [
        "/home/joey/repos/seserver/instances:/appdata/space-engineers/instances"
        "/home/joey/repos/seserver/plugins:/appdata/space-engineers/plugins"
        "/home/joey/repos/seserver/SpaceEngineersDedicated:/appdata/space-engineers/SpaceEngineersDedicated"
        "/home/joey/repos/seserver/entrypoint.sh:/root/entrypoint.sh:ro"
      ];
    };
  };
}
