{ ... }:

{
  imports = [
    ./i3.nix
    ./plasma.nix
  ];

  # config = lib.mkIf cfg.workspace != null
  # this should include hardware.bluetooth and
  # other services we'd like to enable on any
  # workstation
}
