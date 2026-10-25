{
  work =
    pkgs: with pkgs; [
      vlc
      foot
      ffmpeg
      blender
      discord
      spotify
      tor-browser
      proton-vpn
      element-desktop
      nextcloud-client
      nerd-fonts.fira-code
      libreoffice-qt6-fresh
    ];

  dev =
    pkgs: with pkgs; [
      gh
      tmux
      zed-editor
      go
      gopls
      rustup
      gcc
      gdb
      cmake
      ninja
      clang-tools
      nil
      sqlc
      plantuml
      docker-compose
      docker-slim
      apacheHttpd
      pkg-config
      yaml-cpp
      openblas
      systemd
      (python3.withPackages (
        ps: with ps; [
          numpy
          torch
          dask
          seaborn
          plotly
          scikit-learn
          tensorflow
          nltk
          spacy
          pandas
          matplotlib
        ]
      ))
    ];

  kde =
    pkgs: with pkgs.kdePackages; [
      kcalc
      ksystemlog
      kolourpaint
    ];

  util =
    pkgs: with pkgs; [
      fastfetch
      fwupd
      unzip
      tmux
      btop
      zip
      duf
    ];

  games =
    pkgs: with pkgs; [
      prismlauncher
    ];
}
