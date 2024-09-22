{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "intel_iommu=on" "snd_hda_intel.dmic_detect=0" ];
  hardware.enableAllFirmware = true;
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    victor-mono
];
  # Set up the LD_LIBRARY_PATH for all users
  environment.variables = {
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.zlib
      pkgs.expat
      pkgs.minizip
    ];
  };
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
  services.printing.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  users.users.blake = {
    isNormalUser = true;
    description = "blake";
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "kvm"];
  };
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  environment.systemPackages = with pkgs; [
    # home-manager
    vim

    sqlite
    gcc
    gnumake
    cmake
    expat
    zlib
    minizip
    
    fd
    gcc
    gnumake
    cmake
    pkg-config
    expat
    zlib

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
    nodejs
    wget
    syncthing
    thunderbird
    obs-studio
    wine64
    libreoffice-qt
    ungoogled-chromium
    cowsay
    asciiquarium
    redshift
    go
    neovim
    vscodium
    neofetch
    fzf
    yazi
    kitty
    htop
    git
    (python3.withPackages(ps: with ps; [
      pip
      pyautogui
      tkinter
    ]))
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    tmux
    ripgrep
    flatpak

    xclip  # For clipboard support

    gnused  # Make sure sed is installed
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

  environment.etc."xdg/kitty/kitty.conf".text = ''
    scrollback_pager ${pkgs.neovim}/bin/nvim -c "set nonumber nolist showtabline=0 foldcolumn=0" -c "autocmd TermOpen * normal G" -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - " -c "set clipboard=unnamedplus" -c "vmap y ygv\<Esc>" -c "nnoremap y yy" -c "nnoremap Y y$" -c "let @+=@\"" -c "set clipboard=unnamedplus"
    scrollback_lines 10000
    allow_remote_control yes
    map ctrl+shift+s show_scrollback
  '';

    programs.bash = {
      enableCompletion = true;
      interactiveShellInit = ''
        PS1='[\D{%Y-%m-%d}] [\t]:\w\$ '
      '';
    };

  environment.variables = {
      LESS = "-R -X -F";
      LESSHISTFILE = "-"; # Disable .lesshst file
    };

  system.stateVersion = "24.05"; # Did you read the comment?
}
