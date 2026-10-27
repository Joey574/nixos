{ config, ... }:

{
  imports = [ ../modules/system ];
  my.system.unfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
    "nvidia-kernel-modules"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      open = false;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
  };
}
