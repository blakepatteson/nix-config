{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    obs-studio
    ungoogled-chromium
    sqlitebrowser
    lemminx
    google-chrome
    vim
    cargo
    rustup
    delta
    file
    sqlite
    gnumeric
    gh
    graphviz
    flameshot
    nixpkgs-fmt
    acpi
    pkgs.remmina
    clang-tools
    python312Packages.pygments
    docker
    bottom
    xfce.catfish
    pkgs.onlyoffice-bin
    lm_sensors
    bat
    mlocate
    virt-manager
    virt-viewer
    spice-gtk
    OVMF
    glib
    libguestfs
    flyctl
    syncthing
    lazygit
    thunderbird
    wine64
    libreoffice-qt
    cowsay
    asciiquarium
    redshift
    busybox

    rclone
    nodePackages.prettier

    gcc
    gnumake
    cmake
    pkg-config
    expat
    zlib
    minizip
    nodejs
    go
    neovim
    vscodium

    wget
    neofetch
    fzf
    yazi
    kitty
    htop
    git
    tmux
    ripgrep
    flatpak
    xclip
    gnused
    fd
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
