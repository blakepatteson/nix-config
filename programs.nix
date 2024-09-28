{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    file
    sqlite
    flameshot
    docker
    lm_sensors
    teams-for-linux
    virt-manager
    virt-viewer
    spice-gtk
    OVMF
    glib
    libguestfs
    flyctl
    syncthing
    thunderbird
    obs-studio
    wine64
    libreoffice-qt
    ungoogled-chromium
    cowsay
    asciiquarium
    redshift
    busybox

    rclone

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

    (python3.withPackages(ps: with ps; [
      pip
      pyautogui
      tkinter
    ]))
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