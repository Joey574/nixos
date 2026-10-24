{
  config,
  lib,
  pkgs,
  ...
}:

let
  iface = config.my.system.network.privateInterface;
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 8080 ];

  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    package = pkgs.llama-cpp.override { cudaSupport = true; };

    modelsDir = "/var/lib/llama-models";

    extraFlags = [
      "-ngl"
      "99"
      "--jinja"
      "--flash-attn"
      "on"
      "--models-max"
      "1"
      "--no-ui"
      "--cache-type-k"
      "q8_0"
      "--cache-type-v"
      "q8_0"
      "-np"
      "1"
    ];
  };

  systemd.services.llama-cpp.serviceConfig = {
    SupplementaryGroups = [ "video" ];
    ProcSubset = lib.mkForce "all";
  };
}
