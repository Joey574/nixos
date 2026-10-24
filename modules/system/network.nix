{ config, lib, ... }:

let
  net = config.my.system.network;
in
{
  config = lib.mkMerge [
    {
      boot.kernel.sysctl = {
        "net.ipv4.tcp_timestamps" = 0;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "kernel.kptr_restrict" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.perf_event_paranoid" = 2;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;
      };

      networking.hostName = "${net.hostname}";
      networking.networkmanager = {
        enable = true;
        connectionConfig = {
          "ipv4.ignore-auto-dns" = true;
          "ipv6.ignore-auto-dns" = true;
          "ipv6.addr-gen-mode" = "stable-privacy";
        };
      };

      networking.nameservers = [
        "9.9.9.9#dns.quad9.net"
        "1.1.1.1#cloiudflare-dns.com"
      ];

      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNSSEC = "true";
          Domains = [ "~." ];
          DNSOverTLS = "true";
          FallbackDNS = [
            "9.9.9.9#dns.quad9.net"
            "1.1.1.1#cloiudflare-dns.com"
          ];
        };
      };

      services.chrony = {
        enable = true;
        enableNTS = true;
        servers = [
          "time.cloudflare.com"
          "nts.netnod.se"
          "ntppool1.time.nl"
          "ptbtime1.ptb.de"
        ];

        extraConfig = ''
          nocerttimecheck 1
        '';
      };
    }

    (lib.mkIf net.randomizeMac {
      networking.networkmanager = {
        wifi.macAddress = "random";
        wifi.scanRandMacAddress = true;
        ethernet.macAddress = "random";
      };
    })

    (lib.mkIf net.hideHostname {
      services.resolved.settings.Resolve = {
        LLMNR = "false";
        MulticastDNS = "false";
      };

      networking.networkmanager.connectionConfig = {
        "ipv4.dhcp-send-hostname" = false;
        "ipv6.dhcp-send-hostname" = false;
        "ipv6.ipvy-privacy" = 2;
      };
    })
  ];
}
