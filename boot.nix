{ config, pkgs, ... }:
{
  boot.loader = {
    systemd-boot = { enable = true; configurationLimit = 10; };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelParams = [ "intel_iommu=on" "snd_hda_intel.dmic_detect=0" ];
  boot.tmp.cleanOnBoot = true;
  boot.kernel.sysctl = {
    "vm.swappiness" = 10; # Prefer RAM over swap
    "fs.inotify.max_user_watches" = 524288; # For development tools
  };

  hardware.enableAllFirmware = true;
  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
  virtualisation.docker.enable = true;
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
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Power management settings
  services.xserver.displayManager.gdm.autoSuspend = false;
  powerManagement = { enable = false; powertop.enable = false; };
  services.displayManager.defaultSession = "cinnamon";

  # Cinnamon power management settings
  services.xserver.desktopManager.cinnamon.extraGSettingsOverrides = ''
    [org.cinnamon.desktop.session]
    idle-delay=uint32 0

    [org.cinnamon.settings-daemon.plugins.power]
    sleep-display-ac=0
    sleep-inactive-ac-timeout=0
    idle-dim-time=0
    sleep-inactive-battery-timeout=0

    [org.cinnamon.desktop.screensaver]
    lock-enabled=false
  '';

  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.locate = {
    enable = true;
    package = pkgs.mlocate;
    interval = "hourly"; # how often to update the database
    localuser = null; # run updatedb as root
  };
  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
  services.printing.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;
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
    (nerdfonts.override { fonts = [ "VictorMono" ]; })
  ];
  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;
  nix.settings.auto-optimise-store = true;
  services.flatpak.enable = true;
  zramSwap.enable = true;
  services.openssh.enable = true;
  services.fstrim.enable = true;
  services.timesyncd.enable = true;

  security.rtkit.enable = true; # Real-time process priority management
  security.sudo.wheelNeedsPassword = true; # Require password for sudo
  security.auditd.enable = true; # System audit logging

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
    persistent = true;
  };

  users.users.blake = {
    isNormalUser = true;
    description = "blake";
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "video" "kvm" ];
  };
  nix.settings.cores = 0;
  nix.settings.max-jobs = "auto";
  system.stateVersion = "24.05";
}

