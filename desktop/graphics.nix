{
  config,
  lib,
  ...
}:

{
  imports = [ ../modules/system ];

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  my.system.unfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "610.57.04";
      sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
      openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
      settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
      persistencedSha256 = lib.fakeHash; # i have no idea why this works
    };
  };
}
