{ pkgs, ... }:

let
  wgrot = pkgs.buildGoModule {
    pname = "wgrot";
    version = "0-unstable";

    src = pkgs.fetchFromGitHub {
      owner = "Joey574";
      repo = "wgrot";
      rev = "03d21af3c6f60b52a036144df431c133c4ee8ee0";

      hash = "sha256-ryajlejP6r4nA5g+fS+tO7PccMFztN4nSQsTwok5eRs=";
      #hash = pkgs.lib.fakeHash;
    };

    #vendorHash = pkgs.lib.fakeHash;
    vendorHash = "sha256-F+z3KiMIz37YG0ZICqvJJESDdcAAF1cp8ximTGn6FEQ=";
  };
in
{
  environment.systemPackages = [ wgrot ];

  system.activationScripts.netns-dns-dir = {
    text = "mkdir -p /etc/netns/vpn-qbit /etc/netns/vpn-arr";
  };

  systemd.tmpfiles.rules = [
    "d /etc/wgrot-pool 0700 wgrot wgrot -"
  ];

  # vpn namespaces
  systemd.services.netns-vpn = {
    description = "init vpn namespaces";
    before = [
      "wireguard-wg0.service"
      "wireguard-wg1.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "netns-up" ''
        ip=${pkgs.iproute2}/bin/ip

        $ip netns add vpn-qbit || true
        $ip -n vpn-qbit link set lo up

        $ip netns add vpn-arr || true
        $ip -n vpn-arr link set lo up
      '';

      ExecStop = pkgs.writeShellScript "netns-down" ''
        ip=${pkgs.iproute2}/bin/ip
        $ip netns del vpn-qbit || true
        $ip netns del vpn-arr || true
      '';
    };
  };

  # wireguard interface for qbittorrent
  networking.wireguard.interfaces.wg0 = {
    interfaceNamespace = "vpn-qbit";
    privateKeyFile = "/etc/secrets/placeholder.key";

    preSetup = ''
      ${pkgs.iproute2}/bin/ip link del wg0 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip netns add vpn-qbit 2>/dev/null || true
    '';

    postSetup = ''
      ip=${pkgs.iproute2}/bin/ip
      $ip -n vpn-qbit route add default dev wg0
      $ip netns exec vpn-qbit ${pkgs.iproute2}/bin/tc \
        qdisc replace dev wg0 root cake bandwidth 64Mbit

      # give wgrot realtime priority TODO : put this somewhere a bit more relevant
      $ip netns exec vpn-qbit ${pkgs.iptables}/bin/iptables \
        -t mangle -A OUTPUT -m owner --uid-owner wgrot -j DSCP --set-dscp-class EF

      # all requests to 10.2.0.1 get the highest outbound priority
      $ip netns exec vpn-qbit ${pkgs.iptables}/bin/iptables \
        -t mangle -A POSTROUTING -d 10.2.0.1 -j DSCP --set-dscp-class EF

      echo "nameserver 10.2.0.1" > /etc/netns/vpn-qbit/resolv.conf
      echo "hosts: files dns" > /etc/netns/vpn-qbit/nsswitch.conf
    '';
  };

  # wireguard interface for arr applications
  networking.wireguard.interfaces.wg1 = {
    interfaceNamespace = "vpn-arr";
    privateKeyFile = "/etc/secrets/placeholder.key";

    preSetup = ''
      ${pkgs.iproute2}/bin/ip link del wg1 2>/dev/null || true
      ${pkgs.iproute2}/bin/ip netns add vpn-arr 2>/dev/null || true
    '';

    postSetup = ''
      ${pkgs.iproute2}/bin/ip -n vpn-arr route add default dev wg1
      echo "nameserver 10.2.0.1" > /etc/netns/vpn-arr/resolv.conf
      echo "hosts: files dns" > /etc/netns/vpn-arr/nsswitch.conf
    '';
  };

  systemd.services.wireguard-wg0 = {
    requires = [ "netns-vpn.service" ];
    after = [ "netns-vpn.service" ];
    partOf = [ "netns-vpn.service" ];
  };

  systemd.services.wireguard-wg1 = {
    requires = [ "netns-vpn.service" ];
    after = [ "netns-vpn.service" ];
    partOf = [ "netns-vpn.service" ];
  };

  # wgrot user
  users.users.wgrot = {
    isSystemUser = true;
    group = "wgrot";
  };
  users.groups.wgrot = { };

  # rotator for wg0 interface
  systemd.services.wg0-rot = {
    description = "rotate wg0 peer from pool";
    after = [ "wireguard-wg0.service" ];
    requires = [ "wireguard-wg0.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.wireguard-tools
      pkgs.iproute2
      pkgs.libnatpmp
      wgrot
    ];

    serviceConfig = {
      Type = "simple";
      User = "wgrot";
      Group = "wgrot";
      NetworkNamespacePath = "/var/run/netns/vpn-qbit";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-qbit/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-qbit/nsswitch.conf:/etc/nsswitch.conf"
      ];

      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];

      StateDirectory = "wgrot";
      RuntimeDirectory = "wgrot";
      RuntimeDirectoryMode = "0755";

      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = ''
        ${wgrot}/bin/wgrot \
          -iface wg0 \
          --skip-refresh \
          --port-forward \
          --publish-port /run/wgrot/qbit-port
      '';
    };
  };

  # rotator for wg1 interface
  systemd.services.wg1-rot = {
    description = "rotate wg1 peer from pool";
    after = [ "wireguard-wg1.service" ];
    requires = [ "wireguard-wg1.service" ];
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.wireguard-tools
      pkgs.iproute2
      pkgs.libnatpmp
      wgrot
    ];

    serviceConfig = {
      Type = "simple";
      User = "wgrot";
      Group = "wgrot";
      NetworkNamespacePath = "/var/run/netns/vpn-arr";
      BindReadOnlyPaths = [
        "/etc/netns/vpn-arr/resolv.conf:/etc/resolv.conf"
        "/etc/netns/vpn-arr/nsswitch.conf:/etc/nsswitch.conf"
      ];

      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];

      StateDirectory = "wgrot";
      RuntimeDirectory = "wgrot";
      RuntimeDirectoryMode = "0755";

      Restart = "on-failure";
      RestartSec = "10s";

      ExecStart = ''
        ${wgrot}/bin/wgrot \
          -iface wg1 \
          --skip-refresh
      '';
    };
  };
}
