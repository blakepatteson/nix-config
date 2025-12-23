{ pkgs, ... }:

let
  unstable = import
    (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz")
    { config = pkgs.config; system = pkgs.stdenv.hostPlatform.system; };
in
{
  environment.systemPackages = with pkgs; [
    unstable.claude-code

    OVMF
    acpi
    asciiquarium
    bat
    bibata-cursors
    bottom
    brightnessctl
    btop
    busybox
    capitaine-cursors
    cifs-utils
    clang-tools
    cloc
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
    flatpak
    fluidsynth
    flyctl
    fzf
    gcc
    gemini-cli
    gh
    gimp
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
    libva-vdpau-driver
    libvdpau
    lm_sensors
    minizip
    mlocate
    mpv
    neofetch
    nil
    nixd
    nixpkgs-fmt
    nodePackages.prettier
    nodejs
    obs-studio
    odin
    ols
    onlyoffice-desktopeditors
    pamixer
    pavucontrol # Audio control panel
    pinta
    pkg-config
    pulseaudio
    pwvucontrol # PipeWire volume control
    python3
    qsynth
    raylib
    rclone
    redshift
    ripgrep
    rofi
    slurp
    soundfont-fluid
    spice-gtk
    spice-vdagent
    sqlite
    sqlitebrowser
    swappy
    swaybg
    syncthing
    thunderbird
    tmux
    ungoogled-chromium
    virt-manager
    waybar
    wdisplays # GUI display configuration
    wget
    wine64
    wl-clipboard
    wl-mirror
    wofi
    wtype
    x265
    xclip
    xdotool
    xfce.catfish
    xsel
    xwayland-satellite
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

    (flameshot.override { enableWlrSupport = true; })
    (btop.override { cudaSupport = true; })
  ];
}
