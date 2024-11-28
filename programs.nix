{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
    obs-studio
    lm_sensors
    bat
    mlocate
    teams-for-linux
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
    obs-studio
    wine64
    libreoffice-qt
    ungoogled-chromium
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
    # nodePackages."@sveltejs/vite-plugin-svelte" 

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
