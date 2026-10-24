{ pkgs, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = true;
        command_timeout = 1300;
        scan_timeout = 50;

        format = builtins.concatStringsSep "" [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_status"
          "$nix_shell"
          "$c"
          "$python"
          "$golang"
          "$haskell"
          "$rust"
          "$lua"
          "$time"
          "$cmd_duration"
          "$character"
        ];

        username = {
          show_always = true;
          format = "[$user]($style)";
          style_user = "bold green";
          style_root = "bold red";
        };

        hostname = {
          ssh_only = false;
          format = "[@$hostname]($style) ";
          style = "bold green";
        };

        directory = {
          truncation_length = 3;
          truncation_symbol = "…/";
          style = "bold cyan";
        };

        git_branch.format = "[$symbol$branch]($style) ";
        git_commit.format = "[$hash$tag]($style)";
        git_state.format = "[$state($progress_current/$progress_total)]($style)";
        git_status.format = "([$all_status$ahead_behind]($style) )";

        nix_shell = {
          format = "[$symbol$state]($style) ";
          symbol = " ";
        };

        cmd_duration = {
          min_time = 500;
          format = "[$duration]($style) ";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[✗](bold red)";
        };
      };
    };

    programs.bash.interactiveShellInit = ''
      eval "$(${pkgs.starship}/bin/starship init bash)"
      ${pkgs.fastfetch}/bin/fastfetch
    '';
  };
}
