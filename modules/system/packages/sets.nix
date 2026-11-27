{
  work =
    pkgs: with pkgs; [
      vlc
      foot
      nmap
      ffmpeg
      blender
      discord
      spotify
      proton-vpn
      dbeaver-bin
      tor-browser
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
    pkgs: (with pkgs.kdePackages; [
      kcalc
      ksystemlog
      kolourpaint
    ]) ++ (with pkgs; [ waypipe ]);

  util =
    pkgs: with pkgs; [
      fastfetch
      busybox
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
      android-tools
    ];
}
