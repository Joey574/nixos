{ lib, ... }:

{
  options.my.system = {
    network = lib.mkOption {
      type = lib.types.submodule {
        options = {
          hostname = lib.mkOption {
            type = lib.types.str;
            description = "Hostname of the server";
          };

          enableSSH = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether or not to enable ssh";
          };

          privateInterface = lib.mkOption {
            type = lib.types.str;
            default = null;
            description = "Name of the private mesh interface.";
          };

          sharedInterface = lib.mkOption {
            type = lib.types.str;
            default = null;
            description = "Name of the shared mesh interface.";
          };

          hardenDNS = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Hardens dns settings, enabling things like DNSoverTLS and DNSEC";
          };

          randomizeMac = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "randomize WiFi and Eth Mac address";
          };

          hideHostname = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Prevent DHCP from sending hostname";
          };
        };
      };
      default = { };
    };

    tuning = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable custom tuning";
          };

          arch = lib.mkOption {
            type = lib.types.str;
            default = null;
            description = "CPU Instruction set";
          };

          tune = lib.mkOption {
            type = lib.types.str;
            default = null;
            description = "CPU Architecture";
          };
        };
      };
      default = { };
    };

    cache = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable private cache usage";
          };

          serve = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable serving private cache";
          };
        };
      };
      default = { };
    };

    exporters = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable prometheus exporters";
          };
        };
      };
      default = { };
    };

    netbird = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable netbird";
          };

          interactive = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable netbird with an interactive login";
          };
        };
      };
      default = { };
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = "User to initialize";
    };

    kernel = lib.mkOption {
      type = lib.types.str;
      default = "linux_6_18";
      description = "Linux kernel package";
    };

    system = lib.mkOption {
      type = lib.types.enum [
        "x86_64-linux"
        "aarch64-linux"
      ];

      default = "x86_64-linux";
      description = "Type of system";
    };

    workspace = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "plasma" ]);
      default = null;
      description = "Workspace to import";
    };

    plasma = lib.mkOption {
      type = lib.types.submodule {
        options = {
          wp-engine = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Builds the wallpaper-engine-plugin for kde";
                };
              };
            };
            default = {};
          };
        };
      };
      default = {};
    };

    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Names of unfree packages to allow";
    };

    packageSets = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames (import ./packages/sets.nix)));
      default = [ ];
      example = [
        "dev"
        "kde"
      ];
      description = "Named groups of packages to install system-wide.";
    };
  };
}
