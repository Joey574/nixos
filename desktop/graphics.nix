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

  # keep an eye on this for updates
  # https://www.nvidia.com/en-us/geforce/drivers
  # make sure stale hashes don't cause problems when
  # updating by modifying each hash so it doesn't match
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "620.73.04";
      sha256_64bit = "sha256-tfLi1dqENbMlOTBAFbib9+si/grsjNaQW3puip+bjxs=";
      openSha256 = "sha256-+GPU2bXC/QWZTt0eH3dTvI0bMAta1GCdU2WFI4E4LWE=";
      settingsSha256 = "sha256-Wrv0F7Eo9X/0Xv5DclI9aIe3FcRtbu9okQJuWBjL8es=";
      persistencedSha256 = lib.fakeHash; # i have no idea why this works
    };
  };
}
