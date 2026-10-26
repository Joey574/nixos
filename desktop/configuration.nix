{ pkgs, ... }:

let
  wallpaperEngine = pkgs.kdePackages.wallpaper-engine-plugin.overrideAttrs(old: {
    pname = "wallpaper-engine-kde-plugin-captsilver";
    version = "1.5";

    src = pkgs.fetchFromGitHub {
      owner = "CaptSilver";
      repo = "wallpaper-engine-kde-plugin";
      rev = "40cf6bdcaec435aeef3a0f3049d6f52b6d5a0b13";
      hash = "sha256-IM6bIXME6/t76js7tC0QIUvzlA47lE/N92/GlXMr3bg=";
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
    ]);
  });
in
{
  imports = [
    ./hardware-configuration.nix
    ../modules/system
    ./backup.nix
    ./graphics.nix
    ./mounts.nix
    ./system.nix
    ./upgrade.nix
  ];

  my.system = {
    network = {
      hostname = "desktop";
      enableSSH = true;
      privateInterface = "nb-wt0";
    };

    cache = {
      enable = false;
      serve = true;
    };

    kernel = "linux_zen";
    tuning = {
      enable = true;
      arch = "znver4";
      tune = "znver4";
    };

    netbird = {
      enable = true;
      interactive = true;
    };

    user = "joey";
    workspace = "plasma";

    packageSets = [
      "dev"
      "kde"
      "util"
      "work"
      "games"
    ];
  };

  environment.systemPackages = ([
    wallpaperEngine
  ]) ++ (with pkgs.kdePackages; [
    qtwebengine
    qtwebchannel
    qtwebengine
  ]);

  networking.hostId = "cabecee6";

  system.stateVersion = "26.05";
}
