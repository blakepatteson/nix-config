{ pkgs, ... }:

let
  unstable = import
    (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz")
    { config = pkgs.config; system = pkgs.stdenv.hostPlatform.system; };

  emoji-picker = pkgs.writeShellScriptBin "emoji-picker" (
    builtins.readFile ../scripts/user/emoji-picker.sh);
  flameshot-script = pkgs.writeShellScriptBin "flameshot-screenshot" (
    builtins.readFile ../scripts/user/flameshot.sh);
  mkbox = pkgs.writeShellScriptBin "mkbox" (
    builtins.readFile ../scripts/user/mkbox.sh);
  mkwindows = pkgs.writeShellScriptBin "mkwindows" (
    builtins.readFile ../scripts/user/mkwindows.sh);
  niri-dev-setup = pkgs.writeShellScriptBin "niri-dev-setup" (
    builtins.readFile ../scripts/user/niri-dev-setup.sh);
in
{
  environment.systemPackages = with pkgs; [
    emoji-picker
    flameshot-script
    mkbox
    mkwindows
    niri-dev-setup
    unstable.claude-code
    xwayland-satellite

    (flameshot.override { enableWlrSupport = true; })

    OVMF
    acpi
    asciiquarium
    bat
    bottom
    brightnessctl
    btop
    busybox
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
    mpv
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
    nil
    nixd
    nixpkgs-fmt
    nodePackages.prettier
    nodejs
    obs-studio
    odin
    ols
    onlyoffice-desktopeditors

    # Cursor themes
    bibata-cursors
    capitaine-cursors

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
    rofi
    slurp
    soundfont-fluid
    swappy
    spice-gtk
    spice-vdagent
    sqlite
    sqlitebrowser
    swaybg
    syncthing
    thunderbird
    tmux
    ungoogled-chromium
    libva-vdpau-driver
    virt-manager
    waybar
    wdisplays # GUI display configuration
    wget
    wine64
    wl-clipboard
    wofi
    wtype
    x265
    xclip
    xdotool
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
