{ pkgs, lib, ... }:

let
  topoview = pkgs.buildGoModule {
    pname = "topoview";
    version = "0-unstable";

    src = pkgs.fetchFromGitHub {
      owner = "Joey574";
      repo = "topography";
      rev = "4dedb2baa0bcca647875283c496952cbb63a6197";

      hash = lib.fakeHash;
    };

    vendorHash = lib.fakeHash;
    ldFlags = [
      "-s"
      "-w"
    ];
    meta.mainProgram = "topoview";
  };
in
{
  systemd.services.topoview = {
    description = "topoview service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = lib.getExe topoview;
      Restart = "on-failure";
      RestartSec = "10s";

      DynamicUser = true;
      StateDirectory = "topoview";
      UMask = "0077";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateDevices = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";

      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictNamespace = true;

      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      SystemCallArchitectures = [ "native" ];
      SystemCallFilter = [
        "@system-service ~@privileged"
        "~@resources"
      ];
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];

      IPAddressDeny = "any";
      IPAddressAllow = [
        "127.0.0.0/8"
        "::1"
      ];
    };
  };
}
