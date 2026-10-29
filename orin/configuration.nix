{ lib, pkgs, ... }:

let
  jetpackSrc = builtins.fetchTarball "https://github.com/anduril/jetpack-nixos/archive/825dfea5e2def0681ae95d9af48cfc96473574db/master.tar.gz";
  jetpackOverlay = import "${jetpackSrc}/overlay.nix";
in
{
  imports = [
    (import "${jetpackSrc}/modules/default.nix" jetpackOverlay)
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
    ./llama-cpp.nix
  ];

  my.system = {
    user = "admin";

    network = {
      hostname = "orin";
      enableSSH = true;
      privateInterface = "nb-wt0";
      hardenDNS = false;
    };

    tuning = {
      enable = false;
      arch = "armv8.2-a+crypto+fp16+dotprod+rcpc";
      tune = "cortex-a78ae";
    };

    cache.enable = true;
    netbird.enable = true;
    exporters.enable = true;

    system = "aarch64-linux";
    kernel = "linux_5_15";

    unfreePackages = [
      "cuda_cccl"
      "cuda_cudart"
      "cuda_nvcc"
      "libcublas"
    ];

    packageSets = [ "util" ];
  };

  nix.nixPath = [
    "nixpkgs=https://github.com/NixOS/nixpkgs/archive/714a5f8c4ead6b31148d829288440ed033ccc041.tar.gz"
    "nixos-unstable=https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  # cuda memory cannot be swapped, enabling zram increases system instability
  zramSwap.enable = lib.mkForce false;

  hardware.nvidia-jetpack = {
    enable = true;
    majorVersion = "6";
    som = "orin-agx";
    carrierBoard = "devkit";
  };

  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    python3Packages.huggingface-hub
  ];

  system.stateVersion = "26.05";
}
