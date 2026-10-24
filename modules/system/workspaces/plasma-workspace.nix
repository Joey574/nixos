{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.system;
in
{
  config = lib.mkIf (cfg.workspace == "plasma") {
    users.users.${cfg.user}.extraGroups = [
      "networkmanager"
      "wireshark"
      "docker"
    ];

    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    hardware.bluetooth.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.printing.enable = true;
    services.udisks2.enable = true;

    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    programs.ssh = {
      startAgent = true;
      askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    };
    environment.variables.SSH_ASKPASS_REQUIRE = "prefer";

    programs.partition-manager.enable = true;
    programs.nix-ld.enable = true;
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    programs.firefox = {
      enable = true;

      policies = {
        DisableTelemetry = true;

        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };
      };
    };
  };
}
