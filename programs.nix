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
    unstable.claude-code

    OVMF
    acpi
    asciiquarium
    bat
    bottom
    brightnessctl
    btop
    busybox
    clang-tools
    cmake
    cowsay
    cups
    direnv
    docker
    dunst
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
    grim
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    hplip
    htop
    hyprpaper
    imagemagick
    jq
    kitty
    lazygit
    lemminx
    libde265
    libdrm
    libguestfs
    libnotify
    libreoffice-qt
    libva
    libvdpau
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
    pamixer
    pavucontrol # Audio control panel
    pinta
    pkg-config
    pulseaudio
    pwvucontrol # PipeWire volume control
    python312Packages.pygments
    qsynth
    raylib
    rclone
    redshift
    ripgrep
    slurp
    soundfont-fluid
    spice-gtk
    spice-vdagent
    sqlite
    sqlitebrowser
    swaybg
    syncthing
    thunderbird
    tmux
    ungoogled-chromium
    vaapiVdpau
    vim
    virt-manager
    waybar
    wdisplays # GUI display configuration
    wget
    wine64
    wl-clipboard
    wofi
    x265
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
