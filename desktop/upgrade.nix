{ pkgs, ... }:

{
  systemd.services.fleet-upgrade = {
    path = with pkgs; [
      nix
      git
      bash
      openssh
    ];
    serviceConfig.Type = "oneshot";

    # TODO
    # need to add a way for root to do deployments without interaction
    # nixbuild is a trusted user, that's probably all i need to do
    script = ''
      nix-channel --update
    '';
  };

  systemd.timers.fleet-upgrade = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
    };
  };
}
