{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.system;

  wallpaperEngine = pkgs.kdePackages.wallpaper-engine-plugin.overrideAttrs(old: {
    pname = "wallpaper-engine-kde-plugin-captsilver";
    version = "1.5-unstable";

    src = pkgs.fetchFromGitHub {
      owner = "CaptSilver";
      repo = "wallpaper-engine-kde-plugin";
      rev = "ae6c7539bc8ddaf9e0531f88d83eb9dc454aec15";
      hash = "sha256-j+Z8iZcP9lyEZ7cJ6G8eSkzrnL4k4RfDGMj/Z2EMhQo=";
      fetchSubmodules = true;
    };

    patches = [];
    postInstall = "";

    buildInputs = (old.buildInputs or []) ++ (with pkgs.kdePackages; [
      qtdeclarative
      qtwebchannel
      qtwebengine
      kconfig
      kcoreaddons
      kcrash
      kglobalaccel
      ki18n
      knotifications
      kxmlgui
      plasma5support
    ]) ++ (with pkgs; [
      vulkan-headers
      vulkan-loader
      libGL
      libpulseaudio
      fontconfig
      freetype
      libass
    ]);
  });
in
{
  config = lib.mkMerge [
    (lib.mkIf (cfg.workspace == "plasma") {
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
    })

    (lib.mkIf ((cfg.workspace == "plasma") && cfg.plasma.wp-engine.enable) {
      environment.systemPackages = ([
        wallpaperEngine
      ]) ++ (with pkgs.kdePackages; [
        qtwebengine
        qtwebchannel
        qtwebengine
      ]);
    })
  ];
}
