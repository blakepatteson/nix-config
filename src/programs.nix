{ pkgs, pkgs-unstable, isPrimeSystem, ... }:

let
  boltLauncher =
    if isPrimeSystem then
      pkgs.symlinkJoin
        {
          name = "bolt-launcher";
          paths = [ pkgs-unstable.bolt-launcher ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/bolt-launcher \
              --set __NV_PRIME_RENDER_OFFLOAD 1 \
              --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
              --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
          '';
        } else pkgs-unstable.bolt-launcher;
in
{
  environment.systemPackages = with pkgs; [
    pkgs-unstable.claude-code
    boltLauncher

    (btop.override { cudaSupport = true; })
    satty
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
    xfce.catfish
    cifs-utils
    clang-tools
    cloc
    cmake
    cowsay
    dig
    dunst
    eslint
    eslint_d
    expat
    eza
    fastfetch
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
    mpv
    ncdu
    nil
    nixd
    nixpkgs-fmt
    nodejs
    obs-studio
    odin
    ols
    onlyoffice-desktopeditors
    p7zip
    pamixer
    pavucontrol # Audio control panel
    pinta
    pkg-config
    prettier
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
    sqlite
    sqlitebrowser
    svelte-language-server
    swappy
    swaybg
    thunderbird
    typescript
    typescript-language-server
    ungoogled-chromium
    virt-manager
    vscode-langservers-extracted
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
    xsel
    xwayland-satellite
    yazi
    zig
    zlib
    zoom-us
  ];
}
