{
  config,
  lib,
  pkgs,
  ...
}:

let
  iface = config.my.system.network.privateInterface;

  llama-cpp =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
    }).overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [
        "-DGGML_CUDA_NO_VMM=ON"
      ];
  });
in
{
  networking.firewall.interfaces.${iface}.allowedTCPPorts = [ 8080 ];

  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    package = llama-cpp;

    modelsDir = "/var/lib/llama-models";

    extraFlags = [
      "--flash-attn"
      "on"

      "--fit"
      "on"

      "--fit-target"
      "6144"

      "--ctx-size"
      "8192"

      "--cache-type-k"
      "q8_0"
      "--cache-type-v"
      "q8_0"

      "--models-max"
      "1"

      "--cache-ram"
      "1024"

      "--jinja"
      "--no-ui"
    ];
  };

  systemd.services.llama-cpp.serviceConfig = {
    SupplementaryGroups = [ "video" ];
    ProcSubset = lib.mkForce "all";

    MemoryHigh = "46G";
    MemoryMax = "52G";
    MemorySwapMax = "1G";

    OOMPolicy = "kill";

    Restart = "on-failure";
    RestartSec = lib.mkForce "30s"; # why the hell do i need to add mkforce here?
  };
}
