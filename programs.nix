{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    OVMF
    acpi
    asciiquarium
    bat
    bottom
    busybox
    clang-tools
    cmake
    cowsay
    cups
    direnv
    docker
    expat
    fd
    file
    flameshot
    flatpak
    fluidsynth
    flyctl
    fzf
    gcc
    gh
    git
    glib
    gnumake
    gnumeric
    gnused
    go
    golangci-lint
    google-chrome
    graphviz
    hplip
    htop
    kitty
    lazygit
    lemminx
    libguestfs
    libreoffice-qt
    lm_sensors
    minizip
    mlocate
    neofetch
    neovim
    nil
    nixd
    nixpkgs-fmt
    nodePackages.prettier
    nodejs
    obs-studio
    onlyoffice-bin
    pinta
    pkg-config
    python312Packages.pygments
    qsynth
    raylib
    rclone
    redshift
    remmina
    ripgrep
    soundfont-fluid
    spice-gtk
    spice-vdagent
    sqlite
    sqlitebrowser
    syncthing
    thunderbird
    tmux
    ungoogled-chromium
    vim
    virt-manager
    vscodium
    wget
    wine64
    xclip
    xfce.catfish
    xsel
    yazi
    zlib
    zoom-us

    nodePackages.svelte-language-server
    nodePackages.typescript-language-server
    nodePackages.typescript

    (python3.withPackages (ps: with ps; [ pip pyautogui tkinter graphviz ]))
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    python3 = pkgs.python3.override {
      packageOverrides = python-self: python-super: {
        tkinter = python-super.tkinter.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [ pkgs.tk ];
        });
      };
    };
  };
}
