{ pkgs, ... }:

let
  unstable = import
    (fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz")
    {
      config = pkgs.config;
      system = pkgs.system;
    };
in
{
  environment.systemPackages = with pkgs; [
    unstable.bolt-launcher
    unstable.claude-code

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
    eza
    fd
    ffmpeg-full
    file
    flameshot
    flatpak
    fluidsynth
    flyctl
    fzf
    gcc
    gemini-cli
    gh
    git
    glib
    gnumake
    gnumeric
    gnused
    go
    golangci-lint
    google-chrome
    gotools
    graphviz
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    hplip
    htop
    kitty
    lazygit
    lemminx
    libde265
    libdrm
    libguestfs
    libreoffice-qt
    libva
    libvdpau
    lm_sensors
    minizip
    mlocate
    neofetch
    nil
    nixd
    nixpkgs-fmt
    nodePackages.prettier
    nodejs
    obs-studio
    onlyoffice-bin
    pinta
    pkg-config
    pulseaudio
    python312Packages.pygments
    qsynth
    raylib
    rclone
    redshift
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
    vaapiVdpau
    virt-manager
    vscodium
    wget
    wine64
    x265
    xclip
    xfce.catfish
    xsel
    yazi
    zig
    zlib
    zoom-us

    nodePackages.svelte-language-server
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.eslint
    nodePackages.eslint_d
    nodePackages.vscode-langservers-extracted

    (python3.withPackages (ps: with ps; [ pip pyautogui tkinter graphviz ]))
    (btop.override { cudaSupport = true; })
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
