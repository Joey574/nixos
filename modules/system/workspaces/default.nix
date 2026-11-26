{ lib, config, ... }:

let
  cfg = config.my.system;
in
{
  imports = [
    ./plasma.nix
  ];

  config = lib.mkIf (cfg.workspace != null) {
    hardware.bluetooth.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    programs.bash.shellAliases.cd = "z";
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.ssh.extraConfig = ''
      Host s1
        Hostname server1
        User admin
        IdentityFile ~/.ssh/id_ed25519_personal
        IdentitiesOnly yes

      Host s2
        Hostname server2
        User admin
        IdentityFile ~/.ssh/id_ed25519_personal
        IdentitiesOnly yes

      Host s3
        Hostname server3
        User admin
        IdentityFile ~/.ssh/id_ed25519_personal
        IdentitiesOnly yes

      Host s4
        Hostname server4
        User admin
        IdentityFile ~/.ssh/id_ed25519_personal
        IdentitiesOnly yes

      Host o
        Hostname orin
        User admin
        IdentityFile ~/.ssh/id_ed25519_personal
        IdentitiesOnly yes

      Host l
        Hostname laptop
        User joey
        IdentityFile ~/.ssh/id_ed25519_personal
        IdentitiesOnly yes

        Host d
          Hostname desktop
          User joey
          IdentityFile ~/.ssh/id_ed25519_personal
          IdentitiesOnly yes
    '';
  };
}
