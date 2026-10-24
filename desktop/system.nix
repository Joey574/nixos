{ lib, ... }:

let
  archFeatures =
    arch:
    [ "gccarch-${arch}" ]
    ++ map (a: "gccarch-${a}") (lib.systems.architectures.inferiors.${arch} or [ ]);

  orinArch = "armv8.2-a+crypto+fp16+dotprod+rcpc";
  orinFeatures = archFeatures "armv8.2-a" ++ [ "gccarch-${orinArch}" ];
in
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.ssh.knownHosts = {
    laptop.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ0Q2S0fMaE9XTlyGLoT4hiDh1P2CHVz2FOGKSwK9Fcj root@laptop";
    orin.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRG8U9UPd8qMOnxAgCAp16dEUWVJN1GBv7eCBxF4Z8N root@nixos";
    server2.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhQ4Zx5Ue+rVNozxGo8L5TmoXC5rRE0mKcUrZD+gyPN root@server2";
    server3.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP8pmN4P18sD0PJJPSxPprH0gAS+XGnW/B4HkF9wfSx+ root@server3";
    server4.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGVMfax0kp43YRhkLrl6uyV23mp6a8wO+fw3mQlER/v root@server4";
  };

  nixpkgs = {
    config.allowUnfree = true;

    hostPlatform = {
      system = "x86_64-linux";
      gcc.arch = "znver4";
      gcc.tune = "znver4";
    };
  };

  nix = {
    distributedBuilds = true;
    optimise.automatic = true;

    settings = {
      max-jobs = 8;
      cores = 0;

      keep-going = true;
      builders-use-substitutes = true;

      system-features = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ]
      ++ archFeatures "znver4"
      ++ orinFeatures;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "http://localhost:5000"
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "desktop-cache-1:9EtjPikUe7DJQj8B7yIUIdEkUTm7oaC9iSlzwqg5R5U="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    buildMachines = [
      {
        hostName = "laptop";
        protocol = "ssh-ng";
        sshUser = "nixbuild";
        sshKey = "/root/.ssh/nixbuild";
        systems = [ "x86_64-linux" ];
        maxJobs = 4;
        speedFactor = 4;
        supportedFeatures = [
          "nixos-test"
          "big-parallel"
          "kvm"
        ]
        ++ archFeatures "znver3";
      }
      {
        hostName = "orin";
        protocol = "ssh-ng";
        sshUser = "nixbuild";
        sshKey = "/root/.ssh/nixbuild";
        systems = [ "aarch64-linux" ];
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "kvm"
        ]
        ++ orinFeatures;
      }
      {
        hostName = "server2";
        protocol = "ssh-ng";
        sshUser = "nixbuild";
        sshKey = "/root/.ssh/nixbuild";
        systems = [ "x86_64-linux" ];
        maxJobs = 2;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "kvm"
        ]
        ++ archFeatures "skylake";
      }
      {
        hostName = "server3";
        protocol = "ssh-ng";
        sshUser = "nixbuild";
        sshKey = "/root/.ssh/nixbuild";
        systems = [ "x86_64-linux" ];
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "kvm"
        ]
        ++ archFeatures "haswell";
      }
      {
        hostName = "server4";
        protocol = "ssh-ng";
        sshUser = "nixbuild";
        sshKey = "/root/.ssh/nixbuild";
        systems = [ "x86_64-linux" ];
        maxJobs = 2;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "kvm"
        ]
        ++ archFeatures "znver1";
      }
    ];
  };
}
